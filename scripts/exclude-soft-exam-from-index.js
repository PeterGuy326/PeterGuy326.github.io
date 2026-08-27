'use strict';

/**
 * 首页文章流排除「软考」分类
 * --------------------------------------------------------------
 * 软考专题文章数量多、更新频繁，会淹没首页。这里让带「软考」分类的
 * 文章不出现在首页（index）文章流里；归档 /archives/、分类
 * /categories/软考/、标签、站内搜索均不受影响，文章照常可访问，
 * 顶部导航也保留了独立的「软考」入口。
 *
 * 实现原理：Hexo 先加载 node_modules 插件、再加载本 scripts/ 目录，
 * 所以这里用同名的 'index' 生成器覆盖 hexo-generator-index。覆盖时
 * 复用插件的原始逻辑（分页 / 置顶排序 / 读配置），仅在调用前把传入
 * 的 posts 过滤一遍——后续新增的软考文章只要带「软考」分类即自动生效。
 */

const EXCLUDE_CATEGORY = '软考';

const originalIndexGenerator = hexo.extend.generator.get('index');

if (originalIndexGenerator) {
  hexo.extend.generator.register('index', function (locals) {
    const visiblePosts = locals.posts.filter(function (post) {
      return !post.categories.data.some(function (cat) {
        return cat.name === EXCLUDE_CATEGORY;
      });
    });

    const patchedLocals = Object.assign({}, locals, { posts: visiblePosts });

    return originalIndexGenerator.call(this, patchedLocals);
  });
} else {
  hexo.log.warn('[exclude-soft-exam] 未找到 hexo-generator-index，首页过滤未生效');
}
