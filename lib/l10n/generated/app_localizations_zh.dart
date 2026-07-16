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
  String get loopTooltip => '循环播放';

  @override
  String get stopTooltip => '停止';

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
}
