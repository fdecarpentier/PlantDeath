# PlantDeath
**IT ONLY WORKS WITH FIJI, NOT IMAGEJ**
- This macros allows quantification of cell death in plants stained with Evans Blue.
- It is based on the transformation from RGB to CIE L\*a\*b\* images. 
![CIELAB](https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/The_principle_of_the_CIELAB_colour_space.svg/674px-The_principle_of_the_CIELAB_colour_space.svg.png)
- The dead cells are stained in blue while the living cells remains green. 
It is therfore possible to discimiate them based on theire b\* value. 
- The user can chose options: white balance ([original macro](https://github.com/pmascalchi/ImageJ_Auto-white-balance-correction)), whatersheding, scale and minimum area. 
- Examples with Chlamydomonas cells. 

## Original
![original](./input/3.jpg)

## Threshold
![threshold_LAB_b](./output/3_thld_wb_LAB_b.jpg)
![threshold](./output/3_thld_wb.jpg)
![threshold_LAB_b](./output/1_thld_wb_LAB_b.jpg)
![threshold](./output/1_thld_wb.jpg)


## Continuous
![continuous_LAB_b](./output/3_conti_wb_LAB_b.jpg)
![continuous](./output/3_conti_wb.jpg)
![continuous_LAB_b](./output/1_conti_wb_LAB_b.jpg)
![continuous](./output/1_conti_wb.jpg)

## Results Table
Results are tidy! 