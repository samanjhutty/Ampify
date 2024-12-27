sealed class ImageRes {
  static final String thumbnail = _toImages('thumbnail.png');
  static final String userThumbnail = _toImages('user-thumbnail.png');
  static final String history = _toIcons('history.png');
  static final String search = _toIcons('search.png');
  static final String shuffle = _toIcons('shuffle.png');
  static final String musicAlt = _toIcons('music-alt.png');
  static final String music = _toIcons('music.png');

  static String _toIcons(String icon) => 'assets/icons/$icon';
  static String _toImages(String icon) => 'assets/images/$icon';
}
