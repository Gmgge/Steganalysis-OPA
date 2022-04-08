# Steganalysis-OPA-图像隐写
该项目为OPA隐写的简单实验，代码中有详尽的注释用于学习，有任何错误，请不吝赐教。

用例
图像隐写
OPA_stego("../image/6.gif", "hello 这里是南京，很高兴遇到你。 百般欲望昏头重，却看魂随风清悠", 404, "../image/6test.gif")

信息提取
OPA_extract("../image/6test.gif", 404)


1.图像隐写代码下载网站：http://dde.binghamton.edu/download/stego_algorithms

2.图像隐写库：https://github.com/daniellerch/aletheia
