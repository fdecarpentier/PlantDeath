# PlantDeath
**IT ONLY WORKS WITH FIJI, NOT IMAGEJ**
-This macros allows quantification of cell death in plants stained with Evans Blue.
-It is based on the transformation from RGB to CIE L\*a\*b\* images. 
![CIELAB](./CIELAB.png)
-The dead cells are stained in blue while the living cells remains green. 
It is therfore possible to discimiate them based on theire b\* value. 
-The user can chosse options: white balance ([original macro](https://github.com/pmascalchi/ImageJ_Auto-white-balance-correction)), whatersheding, scale and minimum area. 
-Examples with Chlamydomonas cells. 

## Original
![original](./input/eb.jpg)

## Threshold
![threshold_LAB_b](./output/eb_thld_LAB_b.jpg)
![threshold](./output/eb_thld.jpg)
![threshold_LAB_b](./output/3_thld_LAB_b.jpg)
![threshold](./output/3_thld.jpg)


## Continuous
![continuous_LAB_b](./output/eb_conti_LAB_b.jpg)
![continuous](./output/eb_conti.jpg)
![continuous_LAB_b](./output/3_conti_LAB_b.jpg)
![continuous](./output/3_conti.jpg)

## Results Table
Results are tidy! 