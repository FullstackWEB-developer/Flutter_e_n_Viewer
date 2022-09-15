import 'package:flutter/foundation.dart';


@immutable
class Gallery {
  
  const Gallery({
    this.gid,
    this.title,
    this.url,
    this.thumbUrl,
    this.imgHeight,
    this.imgWidth,
  });

  final String? gid;
  final String? title;
  final String? url;
  final String? thumbUrl;
  final int? imgHeight;
  final int? imgWidth;

  factory Gallery.fromJson(Map<String,dynamic> json) => Gallery(
    gid: json['gid'] != null ? json['gid'] as String : null,
    title: json['title'] != null ? json['title'] as String : null,
    url: json['url'] != null ? json['url'] as String : null,
    thumbUrl: json['thumbUrl'] != null ? json['thumbUrl'] as String : null,
    imgHeight: json['imgHeight'] != null ? json['imgHeight'] as int : null,
    imgWidth: json['imgWidth'] != null ? json['imgWidth'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'gid': gid,
    'title': title,
    'url': url,
    'thumbUrl': thumbUrl,
    'imgHeight': imgHeight,
    'imgWidth': imgWidth
  };

  Gallery clone() => Gallery(
    gid: gid,
    title: title,
    url: url,
    thumbUrl: thumbUrl,
    imgHeight: imgHeight,
    imgWidth: imgWidth
  );

    
  Gallery copyWith({
    String? gid,
    String? title,
    String? url,
    String? thumbUrl,
    int? imgHeight,
    int? imgWidth
  }) => Gallery(
    gid: gid ?? this.gid,
    title: title ?? this.title,
    url: url ?? this.url,
    thumbUrl: thumbUrl ?? this.thumbUrl,
    imgHeight: imgHeight ?? this.imgHeight,
    imgWidth: imgWidth ?? this.imgWidth,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is Gallery && gid == other.gid && title == other.title && url == other.url && thumbUrl == other.thumbUrl && imgHeight == other.imgHeight && imgWidth == other.imgWidth;

  @override
  int get hashCode => gid.hashCode ^ title.hashCode ^ url.hashCode ^ thumbUrl.hashCode ^ imgHeight.hashCode ^ imgWidth.hashCode;
}