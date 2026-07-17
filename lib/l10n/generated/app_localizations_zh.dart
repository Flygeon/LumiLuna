// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homeTitle => '媒体库';

  @override
  String get searchHint => '搜索文件名…';

  @override
  String get search => '搜索';

  @override
  String get clear => '清除';

  @override
  String get gridView => '网格视图';

  @override
  String get listView => '列表视图';

  @override
  String get refresh => '刷新';

  @override
  String get settings => '设置';

  @override
  String get loadingError => '加载出错';

  @override
  String get retry => '重试';

  @override
  String get typeImage => '图片';

  @override
  String get typeVideo => '视频';

  @override
  String get typeMusic => '音乐';

  @override
  String get groupAlbum => '相册';

  @override
  String get groupFolder => '文件夹';

  @override
  String get groupDate => '日期';

  @override
  String noItems(Object type) {
    return '没有 $type 文件';
  }

  @override
  String noMatch(Object type) {
    return '没有匹配的 $type';
  }

  @override
  String get emptyAddFolderHint => '在右上角菜单进入设置，添加要扫描的文件夹后下拉刷新';

  @override
  String get tryAnotherKeyword => '换个关键词再试试';

  @override
  String get noGroups => '没有可显示的分组';

  @override
  String get addFolderHint => '在设置中添加要扫描的文件夹后下拉刷新';

  @override
  String itemsCount(Object count) {
    return '$count 个项目';
  }

  @override
  String get nowPlaying => '正在播放';

  @override
  String get notPlaying => '未在播放';

  @override
  String playModeTooltip(String mode) {
    return '播放模式：$mode';
  }

  @override
  String get playModeSequential => '顺序播放';

  @override
  String get playModeLoop => '循环播放';

  @override
  String get playModeShuffle => '随机播放';

  @override
  String get playlist => '播放列表';

  @override
  String get videoTitle => '视频';

  @override
  String imageCounter(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get appearance => '外观';

  @override
  String get defaultGridView => '默认网格视图';

  @override
  String get offListView => '关闭则使用列表视图';

  @override
  String get mediaGrouping => '媒体分组';

  @override
  String get scanFoldersTitle => '扫描文件夹';

  @override
  String get scanFoldersDesc => '应用会递归扫描以下文件夹中的图片、视频和音乐。';

  @override
  String get noFoldersConfigured => '尚未配置，将扫描默认图片 / 视频 / 音乐目录。';

  @override
  String get addFolder => '添加文件夹';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '语言';

  @override
  String get langSystem => '跟随系统';

  @override
  String get langChinese => '简体中文';

  @override
  String get langEnglish => 'English';

  @override
  String get cacheTitle => '缓存';

  @override
  String get clearCache => '清理缓存';

  @override
  String get clearingCache => '正在清理…';

  @override
  String cacheCleared(Object size) {
    return '已清理 $size 缓存';
  }

  @override
  String get about => '关于';

  @override
  String get aboutDesc => '一个 Material Design 媒体库，用于浏览与播放本地的图片、视频和音乐。';

  @override
  String get version => '版本';

  @override
  String get viewLicenses => '开源许可证';

  @override
  String get locateInExplorer => '定位到文件夹';

  @override
  String get favorite => '收藏';

  @override
  String get unfavorite => '取消收藏';

  @override
  String get rename => '重命名';

  @override
  String get renameTitle => '重命名文件';

  @override
  String get renameHint => '新文件名';

  @override
  String get delete => '移到回收站';

  @override
  String confirmDelete(Object name) {
    return '将 $name 移到回收站？';
  }

  @override
  String confirmDeleteMultiple(Object count) {
    return '将 $count 个文件移到回收站？';
  }

  @override
  String confirmPermanentDelete(Object name) {
    return '永久删除 $name？此操作不可撤销。';
  }

  @override
  String get confirmEmptyTrash => '永久删除回收站中所有文件？此操作不可撤销。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '移到回收站';

  @override
  String get restore => '还原';

  @override
  String get deleteForever => '永久删除';

  @override
  String get emptyTrash => '清空回收站';

  @override
  String get trashTitle => '回收站';

  @override
  String get trashEmpty => '回收站为空';

  @override
  String get permanentlyDeleted => '已永久删除';

  @override
  String get restored => '已还原';

  @override
  String movedToTrash(Object name) {
    return '$name 已移到回收站';
  }

  @override
  String operationFailed(Object message) {
    return '操作失败：$message';
  }

  @override
  String get favoritesEmpty => '还没有收藏';

  @override
  String get favoritesEmptyHint => '右键点击任意文件，选择「收藏」即可将其添加到这里。';

  @override
  String get dropFilesHere => '松开鼠标即可导入媒体文件';

  @override
  String importedFiles(Object count) {
    return '已导入 $count 个媒体文件';
  }

  @override
  String importSkippedDuplicates(Object duplicates, Object imported) {
    return '已导入 $imported 个文件，跳过 $duplicates 个重复文件';
  }

  @override
  String get playHistory => '播放历史';

  @override
  String get playHistoryEmpty => '暂无播放记录';

  @override
  String get playHistoryEmptyHint => '播放过的媒体文件会显示在这里。';

  @override
  String get clearHistoryConfirmTitle => '清空播放历史';

  @override
  String get clearHistoryConfirmBody => '确定清空所有播放记录？此操作不可撤销。';

  @override
  String get onboardingSkip => '跳过引导';

  @override
  String get onboardingPrevious => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingStart => '开始使用';

  @override
  String get onboardingWelcomeTitle => '欢迎使用 LumiLuna';

  @override
  String get onboardingWelcomeBody => '在一个简洁的媒体库中浏览、整理和欣赏你的图片、视频与音乐。';

  @override
  String get onboardingLibraryTitle => '自动整理媒体';

  @override
  String get onboardingLibraryBody =>
      '应用会扫描系统默认媒体目录，也可以在设置中添加自己的文件夹。媒体会自动归入图片、视频和音乐标签页。';

  @override
  String get onboardingPlaybackTitle => '沉浸式播放体验';

  @override
  String get onboardingPlaybackBody =>
      '直接打开图片、连续播放视频或管理音乐队列。播放历史会帮你快速找到最近欣赏的内容。';

  @override
  String get onboardingOrganizeTitle => '轻松管理收藏';

  @override
  String get onboardingOrganizeBody => '长按媒体即可批量选择，并进行收藏、删除、添加标签或加入播放列表等操作。';

  @override
  String get sort => '排序';

  @override
  String get sortModified => '按修改时间';

  @override
  String get sortName => '按名称';

  @override
  String get sortSize => '按文件大小';

  @override
  String get sortDuration => '按播放时长';

  @override
  String get sortAscending => '升序';

  @override
  String get sortDescending => '降序';

  @override
  String get playbackSpeed => '播放速度';
}
