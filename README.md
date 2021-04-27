一个用shell写的用来切换pacman软件源的小玩具。

可直接执行脚本，也可以复制到`/usr/bin`下执行

这个脚本对以下两个文件进行操作

`/etc/pacman.d/mirrorlist`和`/etc/pacman.d/mirrorlist.cn`

前者为系统默认的软件源列表，后者是出于使用习惯自行添加的列表。

需要将`/etc/pacman.conf`中`archlinuxcn`源的设置修改为如下形式

```
[archlinuxcn]
Include = /etc/pacman.d/mirrorlist.cn
```

方可正常使用本脚本。

脚本有三个功能，备份&恢复mirrorlist文件，切换软件源。

`./index.sh b` 备份

`./index.sh r` 恢复

`./index.sh w` 切换软件源