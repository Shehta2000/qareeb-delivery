import 'package:sixam_mart_delivery/data/model/response/order_model.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/view/base/custom_image.dart';
import 'package:sixam_mart_delivery/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String image;
  final String? name;
  final DeliveryAddress? address;
  final String? phone;
  final String? latitude;
  final String? longitude;
  final bool showButton;
  final bool isStore;
  final Function? messageOnTap;
  const InfoCard({super.key, required this.title, required this.image, required this.name, required this.address, required this.phone,
    required this.latitude, required this.longitude, required this.showButton, this.messageOnTap, this.isStore = false}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        (name != null && name!.isNotEmpty) ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipOval(child: CustomImage(image: image, height: 40, width: 40, fit: BoxFit.cover)),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(name!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              address!.address ?? '',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor), maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: address!.address != null ? Dimensions.paddingSizeExtraSmall : 0),

            Wrap(children: [
              (address!.streetNumber != null && address!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${address!.streetNumber!}, ',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
              ) : const SizedBox(),

              (address!.house != null && address!.house!.isNotEmpty) ? Text('${'house'.tr}: ${address!.house!}, ',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
              ) : const SizedBox(),

              (address!.floor != null && address!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${address!.floor!}' ,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
              ) : const SizedBox(),

            ]),

            showButton ? Row(children: [

              TextButton.icon(
                onPressed: () async {
                  if(await canLaunchUrlString('tel:$phone')) {
                    launchUrlString('tel:$phone', mode: LaunchMode.externalApplication);
                  }else {
                    showCustomSnackBar('invalid_phone_number_found');
                  }
                },
                icon: Icon(Icons.call, color: Theme.of(context).primaryColor, size: 20),
                label: Text(
                  'call'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ),

              isStore ? TextButton.icon(
                onPressed: messageOnTap as void Function()?,
                icon: Icon(Icons.message, color: Theme.of(context).primaryColor, size: 20),
                label: Text(
                  'chat'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ) : const SizedBox(),

              TextButton.icon(
                onPressed: () async {
                  String url ='https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&mode=d';
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw '${'could_not_launch'.tr} $url';
                  }
                },
                icon: Icon(Icons.directions, color: Theme.of(context).disabledColor, size: 20),
                label: Text(
                  'direction'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
              ),

            ]) : const SizedBox(height: Dimensions.paddingSizeDefault),

          ])),

        ]) : Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Text('no_store_data_found'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)))),

      ]),
    );
  }
}
