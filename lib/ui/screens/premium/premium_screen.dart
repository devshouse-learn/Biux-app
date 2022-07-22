import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/repositories/payments/payments_repository.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'confirm_payment.dart';

class PremiumScreen extends StatefulWidget {
  final String image;
  PremiumScreen(this.image);
  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.plans),
        actions: [],
      ),
      body: ListView(
        children: [
          _widgetCardPremium(
              AppColors.vividOrange,
              AppStrings.gold,
              AppStrings.framework,
              AppStrings.secureFunctions,
              AppStrings.cardsAndQr,
              AppStrings.jerseyOficial,
              AppStrings.cost,
              context),
          _widgetCardPremium(
              AppColors.lightGrey,
              AppStrings.silver,
              AppStrings.framework,
              AppStrings.secureFunctions,
              AppStrings.cardsAndQr,
              '',
              AppStrings.cost2,
              context),
          _widgetCardPremium(
            AppColors.strongOrange,
            AppStrings.bronze,
            AppStrings.framework,
            AppStrings.secureFunctions,
            '',
            '',
            AppStrings.cost3,
            context,
          ),
        ],
      ),
    );
  }

  _widgetCardPremium(
    Color color,
    String mensaje,
    String data1,
    String data2,
    String data3,
    String data4,
    String data5,
    BuildContext context,
  ) {
    return Stack(
      children: <Widget>[
        Container(
          height: mensaje == AppStrings.gold
              ? 240
              : mensaje == AppStrings.silver
                  ? 210
                  : mensaje == AppStrings.bronze
                      ? 190
                      : 240,
          width: 350,
          child: Card(
            color: AppColors.white,
            margin: EdgeInsets.only(
              left: 69,
              bottom: 20,
              top: 20,
            ),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.only(
                        left: 69,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              mensaje,
                              style: Styles.sizedBox,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 35,
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, 16),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.vividBlue,
                          size: 24.0,
                        ),
                      ),
                      Text(
                        data1,
                        style: Styles.accentTextThemeBlack,
                      ),
                      Flexible(
                        child: Container(
                          child: Text(
                            "",
                            overflow: TextOverflow.fade,
                            style: Styles.rowGestureDetector,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 35,
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, 16),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.vividBlue,
                          size: 24.0,
                        ),
                      ),
                      Text(
                        data2,
                        style: Styles.accentTextThemeBlack,
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(right: 13.0),
                          child: Text(
                            "",
                            overflow: TextOverflow.fade,
                            style: Styles.rowGestureDetector,
                          ),
                        ),
                      ),
                    ],
                  ),
                  mensaje == AppStrings.silver || mensaje == AppStrings.gold
                      ? Container(
                          height: 5,
                        )
                      : Container(),
                  mensaje == AppStrings.silver || mensaje == AppStrings.gold
                      ? Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                left: 35,
                              ),
                            ),
                            data3 == ''
                                ? Align()
                                : Align(
                                    alignment: Alignment(0, 16),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: AppColors.vividBlue,
                                      size: 24.0,
                                    ),
                                  ),
                            Text(
                              data3,
                              style: Styles.accentTextThemeBlack,
                            ),
                            Container(
                              width: 5,
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "",
                                  overflow: TextOverflow.fade,
                                  style: Styles.flexibleContainerText,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  mensaje == AppStrings.gold
                      ? Container(
                          height: 5,
                        )
                      : Container(),
                  mensaje == AppStrings.gold
                      ? Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                left: 35,
                              ),
                            ),
                            data4 == ''
                                ? Align()
                                : Align(
                                    alignment: Alignment(0, 16),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: AppColors.vividBlue,
                                      size: 24.0,
                                    ),
                                  ),
                            Text(
                              data4,
                              style: Styles.accentTextThemeBlack,
                            ),
                            Container(
                              width: 5,
                            ),
                            Flexible(
                              child: Container(
                                child: Text(
                                  "",
                                  overflow: TextOverflow.fade,
                                  style: Styles.flexibleContainerText,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  mensaje == AppStrings.gold
                      ? Container(
                          height: 10,
                        )
                      : Container(),
                  GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            left: 35,
                          ),
                        ),
                        Icon(
                          Icons.directions_bike,
                          size: 20,
                        ),
                        Container(
                          width: 5,
                        ),
                        Text(
                          "",
                          textAlign: TextAlign.start,
                          style: Styles.rowGroupNumberMembers,
                        ),
                        Container(
                          width: 10,
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Align(
                      alignment: Alignment(12, 0.6),
                      child: GestureDetector(
                        child: Container(
                          height: 110,
                          width: 105,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                90.0,
                              ),
                            ),
                            border: Border.all(
                              color: color,
                              width: 1.0,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(widget.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    animation: true,
                    radius: 110.0,
                    startAngle: 180.0,
                    percent: 0.2,
                    reverse: false,
                    lineWidth: 5.0,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: color.withOpacity(0),
                    progressColor: color,
                  ),
                  CircularPercentIndicator(
                    animation: true,
                    startAngle: 80.0,
                    reverse: true,
                    radius: 110.0,
                    percent: 0.3,
                    lineWidth: 5.0,
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: color.withOpacity(0.5),
                    progressColor: color,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: mensaje == AppStrings.gold
                      ? 185
                      : mensaje == AppStrings.silver
                          ? 160
                          : mensaje == AppStrings.bronze
                              ? 140
                              : 200,
                  left: 60),
              child: ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                  side: BorderSide(
                    width: 3,
                    color: color,
                  ),
                ),
                minWidth: 35.0,
                height: 35.0,
                child: RaisedButton(
                  color: AppColors.deepNavyBlue,
                  onPressed: () async {
                    var url = await PaymentsRepository().gatewayPayment();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ConfirmPayment(url),
                      ),
                    );
                  },
                  child: Text(
                    data5,
                    style: Styles.raisedButtonSeeMore,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              child: SizedBox(
                width: 95,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 140,
                    left: 8,
                  ),
                  child: Text(
                    "",
                    overflow: TextOverflow.fade,
                    style: Styles.sizedBoxGestureDetector,
                  ),
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
