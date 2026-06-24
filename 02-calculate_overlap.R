library(tidyverse)
library(ciftiTools)

ciftiTools.setOption("wb_path", "/Applications/wb_view.app/Contents/usr/bin/wb_command")

setwd("~/MyDrive/Projects/parcel_overlap//")

# Load data
glasser <- read_cifti("seg-glasser.dlabel.nii")
flipped <- read_cifti("seg-glasserflipped.dscalar.nii")

# Load labels 
labels <- read_table("seg-glasser_labels.txt",
                      col_names = c("X", "R", "G", "B", "A"))

label_names <- str_subset(labels$X, "_ROI")
label_indices <- as.numeric(str_subset(labels$X, "_ROI", negate = TRUE))

rois <- tibble(label = label_names, index = label_indices) %>%
  separate_wider_delim(label, delim = "_", names = c("LR", "label", NA)) %>%
  pivot_wider(names_from = LR, values_from = index)

# Actually do the math

results <- tibble(label = rois$label, sizeL = NA, sizeR = NA, 
                  intersection = NA)

for (i in 1:nrow(rois)) {

  label <- rois$label[i]
  L <- rois$L[i]
  R <- rois$R[i]

  # Extract 1-D matrices and cast to vector
  base <- (glasser$data$cortex_left == L)[, 1]
  flip <- (flipped$data$cortex_left == R)[, 1]

  # The sizes end up different because of the projection
  results$sizeL[i] <- sum(base)
  results$sizeR[i] <- sum(flip)

  results$intersection[i] <- sum(base & flip)

}

results2 <- results %>%
  mutate(
    dice = (2 * intersection) / (sizeL + sizeR)
  ) %>%
  arrange(desc(dice)) %>%
  mutate(
    order = row_number()
  )

library(corrr)

correlate(results2)

ggplot(results2, aes(x = order, y = dice)) +
  geom_point() +
  scale_y_continuous(limits = c(NA, 1)) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

write_csv(results2, "glasser_LR_overlap.csv")

# Distribution of values

library(RcppAlgos)

expand <- comboGrid(results2$label, results2$label) %>%
  as_tibble() %>%
  filter_out(
    Var1 == Var2
  ) %>%
  mutate(
    dice1 = results2$dice[match(Var1, results2$label)],
    dice2 = results2$dice[match(Var2, results2$label)],
    avg_dice = (dice1 + dice2) / 2,
    avg_dice_Z = scale(avg_dice)[, 1]
  )

write_csv(expand, "all_combn_dice.csv")

ggplot(expand, aes(avg_dice)) +
  geom_density() +
  scale_x_continuous(limits = c(NA, 1)) +
  theme_bw()
 