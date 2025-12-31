import 'package:customer/app/models/notification_model.dart';
import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/constant_widgets/container_custom.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final Function onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        extentRatio: 0.20,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(notification),
            backgroundColor: AppThemeData.danger300,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ContainerCustomSub(
        // height: 104.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextCustom(
                  title: notification.title!,
                  fontFamily: FontFamily.medium,
                  fontSize: 16,
                  maxLine: 2,
                ),
                // TextCustom(
                //   title: Constant.timestampToDate(notification.createdAt!),
                //   fontSize: 12,
                //   color: AppThemeData.grey600,
                //   fontFamily: FontFamily.light,
                // ),
              ],
            ),
            spaceH(height: 2.h),
            TextCustom(
              title: notification.description!,
              fontFamily: FontFamily.medium,
              fontSize: 14,
              textAlign: TextAlign.start,
              maxLine: 2,
              color: AppThemeData.grey600,
            ),
          ],
        ),
      ),
    );
  }
}
