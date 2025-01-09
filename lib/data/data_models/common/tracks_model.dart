import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final Album? album;
  final List<Artist>? artists;
  final int? discNumber;
  final int? durationMs;
  final bool? explicit;
  final String? href;
  final String? id;
  final bool? isLocal;
  final bool? isPlayable;
  final String? name;
  final int? popularity;
  final String? previewUrl;
  final int? trackNumber;
  final String? type;
  final String? uri;

  const Track(
      {this.album,
      this.artists,
      this.discNumber,
      this.durationMs,
      this.explicit,
      this.href,
      this.id,
      this.isLocal,
      this.isPlayable,
      this.name,
      this.popularity,
      this.previewUrl,
      this.trackNumber,
      this.type,
      this.uri});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
      artists: List<Artist>.from(
          json['artists']?.map((e) => Artist.fromJson(e)) ?? []),
      discNumber: json['disc_number'],
      durationMs: json['duration_ms'],
      explicit: json['explicit'],
      href: json['href'],
      id: json['id'],
      isLocal: json['is_local'],
      isPlayable: json['is_playable'],
      name: json['name'],
      popularity: json['popularity'],
      previewUrl: json['preview_url'],
      trackNumber: json['track_number'],
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'album': album?.toJson(),
        'artists': artists?.map((v) => v.toJson()).toList(),
        'disc_number': discNumber,
        'duration_ms': durationMs,
        'explicit': explicit,
        'href': href,
        'id': id,
        'is_local': isLocal,
        'is_playable': isPlayable,
        'name': name,
        'popularity': popularity,
        'preview_url': previewUrl,
        'track_number': trackNumber,
        'type': type,
        'uri': uri,
      };

  @override
  List<Object?> get props => [
        album,
        artists,
        discNumber,
        durationMs,
        explicit,
        href,
        id,
        isLocal,
        isPlayable,
        name,
        popularity,
        previewUrl,
        trackNumber,
        type,
        uri,
      ];
}
