# 指定基础镜像 若不需要基础镜像 可以 FROM scratch 虚拟镜像 
FROM nginx:stable-alpine

# RUN 命令 构建镜像时执行的命令，每一个RUN都会新建一个层 所以尽量将一件事情的命令放到一层中，且不可更改的放前面
# 每层构建结束都应该加上清除无用的文件缓存的命令，减少镜像大小

# 两种格式
# shell 格式： eg echo $USER
# exec 格式：["可执行文件", "参数1", "参数2"] 
RUN echo '<h1>Hello World </h1>' > /usr/share/nginx/html/index.html

# COPY 将从构建上下文目录中 <源路径> 的文件/目录复制到新的一层的镜像内的 <目标路径> 位置
# eg COPY package.json /usr/src/app/
# <源路径> 可以是多个，甚至可以是通配符，其通配符规则要满足 Go 的 filepath.Match 规则 eg COPY hom?.txt /mydir/
# <目标路径> 可以是容器内的绝对路径，也可以是相对于工作目录的相对路径（工作目录可以用 WORKDIR 指令来指定）。目标路径不需要事先创建，如果目录不存在会在复制文件前先行创建缺失目录。
# COPY [--chown=<user>:<group>] <源路径>... <目标路径>
# COPY [--chown=<user>:<group>] ["<源路径1>",... "<目标路径>"]
COPY index2.html /usr/share/nginx/html/

# CMD 容器启动时默认的运行命令 docker run 命令 可以指定命令来覆盖这个默认命令 eg docker run --name nginx -d nginx:v2 cat /etc/os-release  最后这个命令就是覆盖了CMD指定的命令
# shell 格式：CMD <命令>
# exec 格式：CMD ["可执行文件", "参数1", "参数2"...]
# 参数列表格式：CMD ["参数1", "参数2"...]。在指定了 ENTRYPOINT 指令后，用 CMD 指定具体的参数。 
# 在指令格式上，一般推荐使用 exec 格式，这类格式在解析时会被解析为 JSON 数组，因此一定要使用双引号 "，而不要使用单引号。
# eg CMD [ "sh", "-c", "echo $HOME" ]
# 命令都是以前台形式执行，不用以后台形式，命令如果执行结束退出 那容器也就结束了
# CMD service nginx start 这种是有问题的， 容器会直接退出

CMD cat $USER

# ENTRYPOINT 入口点
# ENTRYPOINT 的格式和 RUN 指令格式一样，分为 exec 格式和 shell 格式。
# ENTRYPOINT 的目的和 CMD 一样，都是在指定容器启动程序及参数。
# ENTRYPOINT 在运行时也可以替代，不过比 CMD 要略显繁琐，需要通过 docker run 的参数 --entrypoint 来指定。 运行时动态替换dockerfile设置的命令
# 当指定了 ENTRYPOINT 后，CMD 的含义就发生了改变，不再是直接的运行其命令，而是将 CMD 的内容作为参数传给 ENTRYPOINT 指令，换句话说实际执行时，将变为： <ENTRYPOINT> "<CMD>"
# docker run 镜像名 命令CMD 镜像名后面的就是动态指定的CMD命令，如果脚本设置了 ENTRYPOINT 就会将CMD像上面一样附加到后面
# 优势：让镜像变成像命令一样使用 可以根据run时增加的命令参数 动态改变镜像容器的结果
# 应用运行前的准备工作 一些准备工作可以放在 ENTRYPOINT 里面，然后根据传入的参数进行一些逻辑判断走不同的处理情况
# https://yeasy.gitbook.io/docker_practice/image/dockerfile/entrypoint

# ENV 设置环境变量
# 设置 ENV VERSION=1.0 DEBUG=on \
#    NAME="Happy Feet"
# 使用： $VERSION
ENV ENV=product

# ARG 构建参数
# ARG <参数名>[=<默认值>]
# Dockerfile 中的 ARG 指令是定义参数名称，以及定义其默认值。
# 该默认值可以在构建命令 docker build 中用 --build-arg <参数名>=<值> 来覆盖
# 构建参数和 ENV 的效果一样，都是设置环境变量。所不同的是，ARG 所设置的构建环境的环境变量，在将来容器运行时是不会存在这些环境变量的

ARG name 
ARG sex=1

# VOLUME 定义匿名卷
# 将host机上的目录挂载到容器中的路径内 匿名卷的host路径是统一管理的 /var/lib/docker/volumes/...
# eg VOLUME my_volume /data 表示将 /var/lib/docker/volumes/my_volume 目录挂在到容器的 /data 目录下，即在容器/data内写的任何数据都会放在 ../my_volume/下 
# VOLUME /foo 表示创建一个匿名的路径挂在到/foo 下 。类似 /var/lib/docker/volumes/dsdfewdsdressdxx22/ 这种，由docker自己命名
# VOLUME ["<路径1>", "<路径2>"...]
# VOLUME <路径>
VOLUME my_volume /foo
# docker run -v my_volume1:/foo:ro 可以在启动时指定挂载卷 会替换dockerfile中指定的匿名卷 第三个参数指定权限，默认rw可读写，ro为只读

# EXPOSE 暴露端口
# EXPOSE <端口1> [<端口2>...]
# EXPOSE 指令是声明运行时容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就会开启这个端口的服务。在 Dockerfile 中写入这样的声明有两个好处，一个是帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射；另一个用处则是在运行时使用随机端口映射时，也就是 docker run -P 时，会自动随机映射 EXPOSE 的端口

# 要将 EXPOSE 和在运行时使用 -p <宿主端口>:<容器端口> 区分开来。-p，是映射宿主端口和容器端口，换句话说，就是将容器的对应端口服务公开给外界访问，而 EXPOSE 仅仅是声明容器打算使用什么端口而已，并不会自动在宿主进行端口映射。

EXPOSE 8081 8082

# WORKDIR 指定工作目录
# WORKDIR <工作目录路径>
# 使用 WORKDIR 指令可以来指定工作目录（或者称为当前目录），以后各层的当前目录就被改为指定的目录，如该目录不存在，WORKDIR 会帮你建立目录
# 每一个RUN都会创建一层新的镜像，故要想使每一层都指定同一个工作目录可以使用 WORKDIR 指定
WORKDIR /app

# USER 指定当前用户
# USER <用户名>[:<用户组>]
# USER 指令和 WORKDIR 相似，都是改变环境状态并影响以后的层。WORKDIR 是改变工作目录，USER 则是改变之后层的执行 RUN, CMD 以及 ENTRYPOINT 这类命令的身份。
# 和 WORKDIR 一样，USER 只是帮助你切换到指定用户而已，这个用户必须是事先建立好的，否则无法切换。
# RUN groupadd -r redis && useradd -r -g redis redis
# USER redis
# RUN [ "redis-server" ]
USER jh

# HEALTHCHECK 健康检查  指令是告诉 Docker 应该如何进行判断容器的状态是否正常
# HEALTHCHECK [选项] CMD <命令>：设置检查容器健康状况的命令
# HEALTHCHECK NONE：如果基础镜像有健康检查指令，使用这行可以屏蔽掉其健康检查指令
# 当在一个镜像指定了 HEALTHCHECK 指令后，用其启动容器，初始状态会为 starting，在 HEALTHCHECK 指令检查成功后变为 healthy，如果连续一定次数失败，则会变为 unhealthy
# HEALTHCHECK 支持下列选项：
# --interval=<间隔>：两次健康检查的间隔，默认为 30 秒；
# --timeout=<时长>：健康检查命令运行超时时间，如果超过这个时间，本次健康检查就被视为失败，默认 30 秒；
# --retries=<次数>：当连续失败指定次数后，则将容器状态视为 unhealthy，默认 3 次
# 和 CMD, ENTRYPOINT 一样，HEALTHCHECK 只可以出现一次，如果写了多个，只有最后一个生效
# 在 HEALTHCHECK [选项] CMD 后面的命令，格式和 ENTRYPOINT 一样，分为 shell 格式，和 exec 格式。命令的返回值决定了该次健康检查的成功与否：0：成功；1：失败；2：保留，不要使用这个值
HEALTHCHECK --interval=30s --timeout=3s CMD curl -fs http://localhost || exit 1

# ONBUILD 在别人的镜像依赖自己时执行的命令，可以方便管理 在自己的镜像构建时并不会执行
ONBUILD COPY ./package.json /app/package.json
ONBUILD RUN ["whoami"]

# 多阶段构建 一个dockerfile 可以有多个 FROM ... 可以加别名 as ... . 构建时使用 docker build --target=别名 来构建某一个镜像
# 多阶段构建可以明显减少镜像大小，优化

