# newMultitaskingSwitcherLayout
实现iOS8-10的后台多任务切换器

支持swift

# 简单使用:

创建一个layout对象

newMultitaskingSwitcherLayout *layout = [[newMultitaskingSwitcherLayout alloc]init];

如果要切换成不同ios版本的后台:

layout.style = styleiOS8;

![image](https://github.com/miku1958/newMultitaskingSwitcherLayout/blob/master/截图/8.gif?raw=true)

styleiOS9_10

![image](https://github.com/miku1958/newMultitaskingSwitcherLayout/blob/master/截图/910.gif?raw=true)

styleiOS10LessMotion

![image](https://github.com/miku1958/newMultitaskingSwitcherLayout/blob/master/截图/10l.gif?raw=true)



styleiOS9_10的代码参考于 https://github.com/zqpmaster/MXCardLayout
做了一些bug的修复,并且把定位视图设定到了正中间


# 已知问题
由于pan手势不能自定义translation的反馈比例(速度比),所以我把collectionView的pan手势替换了,如果collectionView要setCollectionViewLayout的话最好运行一下这个方法
layout.restroeOriginalPanGesture;

同上,setCollectionViewLayout时的动画会异常,但我测试了其他人的layout也会异常,所以可能是苹果重构了UICollectionview后的bug(期望是,因为为找不到原因)

自定义itemSize最好不要小于屏幕的一半大小,MXCardLayout的算法有点问题,cell会直接消失
