import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/dimens.dart';

class Shimmer {
  static get avatar => const _Shimmer(borderRadius: 50);
  static get box => const _Shimmer();
}

class _Shimmer extends StatelessWidget {
  final double? borderRadius;
  const _Shimmer({this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: ColorRes.shimmer,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0))),
    );
  }
}

class SongTileShimmer extends StatelessWidget {
  final EdgeInsets? margin;
  final double? iconSize;
  const SongTileShimmer({super.key, this.margin, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.fromLTRB(
            Dimens.sizeDefault,
            Dimens.sizeSmall,
            Dimens.sizeLarge,
            Dimens.sizeSmall,
          ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: iconSize ?? 50,
            child: Shimmer.box,
          ),
          const SizedBox(width: Dimens.sizeDefault),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15, width: 200, child: Shimmer.box),
              const SizedBox(height: Dimens.sizeMedSmall),
              SizedBox(
                  height: 15, width: context.width * .7, child: Shimmer.box),
            ],
          )
        ],
      ),
    );
  }
}

class PlaylistShimmer extends StatelessWidget {
  final double? imageSize;
  const PlaylistShimmer({super.key, this.imageSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(backgroundColor: Colors.white),
        SizedBox.square(
          dimension: imageSize ?? context.height * .3,
          child: Shimmer.box,
        ),
        Container(
          margin: const EdgeInsets.all(Dimens.sizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 25,
                width: context.width * .6,
                child: Shimmer.box,
              ),
              const SizedBox(height: Dimens.sizeSmall),
              SizedBox(height: 15, width: double.infinity, child: Shimmer.box),
              const SizedBox(height: Dimens.sizeSmall),
              SizedBox(height: 15, width: double.infinity, child: Shimmer.box),
              const SizedBox(height: Dimens.sizeSmall),
              Row(
                children: [
                  SizedBox(
                      height: 30,
                      width: context.width * .4,
                      child: Shimmer.avatar),
                  const SizedBox(width: Dimens.sizeSmall),
                  SizedBox(
                      height: 15,
                      width: context.width * .3,
                      child: Shimmer.box),
                ],
              )
            ],
          ),
        ),
        Row(
          children: [
            const SizedBox(width: Dimens.sizeDefault),
            const Icon(
              Icons.add_circle_outline,
              size: Dimens.sizeMidLarge + 4,
              color: ColorRes.shimmer,
            ),
            const SizedBox(width: Dimens.sizeDefault),
            const Icon(
              Icons.more_vert,
              size: Dimens.sizeMidLarge,
              color: ColorRes.shimmer,
            ),
            const Spacer(),
            SizedBox.square(dimension: 50, child: Shimmer.avatar),
            const SizedBox(width: Dimens.sizeDefault),
          ],
        ),
        Expanded(
          child: ListView.builder(
              itemCount: 5,
              padding: const EdgeInsets.only(top: Dimens.sizeDefault),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                return const SongTileShimmer();
              }),
        )
      ],
    );
  }
}
