import 'package:sixam_mart_delivery/controller/order_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/view/base/custom_app_bar.dart';
import 'package:sixam_mart_delivery/view/screens/order/widget/history_order_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key}) ;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    Get.find<OrderController>().getCompletedOrders(1);

    return Scaffold(
      appBar: CustomAppBar(title: 'my_orders'.tr, isBackButtonExist: false),
      body: GetBuilder<OrderController>(builder: (orderController) {
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
                  scrollController.position.maxScrollExtent &&
              orderController.completedOrderList != null &&
              !Get.find<OrderController>().paginate) {
            int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
            if (Get.find<OrderController>().offset < pageSize) {
              Get.find<OrderController>()
                  .setOffset(Get.find<OrderController>().offset + 1);
              // > debugPrint('end of the page');
              Get.find<OrderController>().showBottomLoader();
              Get.find<OrderController>()
                  .getCompletedOrders(Get.find<OrderController>().offset);
            }
          }
        });

        return orderController.completedOrderList != null
            ? orderController.completedOrderList!.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () async {
                      await orderController.getCompletedOrders(1);
                    },
                    child: Scrollbar(
                        child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                          child: SizedBox(
                        width: 1170,
                        child: Column(children: [
                          ListView.builder(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            itemCount:
                                orderController.completedOrderList!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return HistoryOrderWidget(
                                  orderModel: orderController
                                      .completedOrderList![index],
                                  isRunning: false,
                                  index: index);
                            },
                          ),
                          orderController.paginate
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(
                                      Dimensions.paddingSizeSmall),
                                  child: CircularProgressIndicator(),
                                ))
                              : const SizedBox(),
                        ]),
                      )),
                    )),
                  )
                : Center(child: Text('no_order_found'.tr))
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
