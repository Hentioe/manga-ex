# Manga

Export mangas from the website, use Elixir/Erlang to achieve!

## 说明

将漫画网站的资源直接导出为离线阅读文件（EPUB/MOBI/PDF）。此项目正处于开发阶段：）


## TODO

- [x] 基础资源爬取功能
- [x] 下载模块基础实现
- [x] 图片合并为 .epub
- [x] 基于 URL 参数类型识别的 CLI 导出功能
- [x] 基于手动交互的 CLI 导出功能
- [ ] 改善输出格式（抓取和下载过程更新在同一行输出上）
- [ ] 并发抓取/下载以及相应的并发量限制
- [ ] 自动构建缓存目录（资源以及配置）
- [ ] 更多的资源来源支持
- [ ] 更多的导出格式支持
