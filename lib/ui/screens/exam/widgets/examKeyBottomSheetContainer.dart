import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamKeyBottomSheetContainer extends StatefulWidget {
  final Exam exam;
  ExamKeyBottomSheetContainer({Key? key, required this.exam}) : super(key: key);

  @override
  _ExamKeyBottomSheetContainerState createState() => _ExamKeyBottomSheetContainerState();
}

class _ExamKeyBottomSheetContainerState extends State<ExamKeyBottomSheetContainer> {
  late TextEditingController textEditingController = TextEditingController();

  late String errorMessage = "";

  Widget _buildExamRuleContainer(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 7.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(3)),
          ),
          SizedBox(
            width: 10.0,
          ),
          Flexible(
              child: Text(
            rule,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              height: 1.2,
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<ExamCubit>().state is ExamFetchInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: BlocListener<ExamCubit, ExamState>(
        bloc: context.read<ExamCubit>(),
        listener: (context, state) {
          if (state is ExamFetchFailure) {
            setState(() {
              errorMessage = AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!;
            });
          } else if (state is ExamFetchSuccess) {
            Navigator.of(context).pushReplacementNamed(Routes.exam);
          }
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (0.95),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter)),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.all(10.0),
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            onPressed: () {
                              if (context.read<ExamCubit>().state is! ExamFetchInProgress) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              size: 28.0,
                              color: Theme.of(context).primaryColor,
                            )),
                      ),
                    ],
                  ),

                  //
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * (0.125),
                    ),
                    padding: EdgeInsetsDirectional.only(start: 20.0),
                    height: 60.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: TextField(
                      controller: textEditingController,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppLocalization.of(context)!.getTranslatedValues(enterExamKey)!,
                        hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.02),
                  ),

                  //show any error message
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    child: errorMessage.isEmpty
                        ? SizedBox(
                            height: 20.0,
                          )
                        : Container(
                            height: 20.0,
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * (errorMessage.isEmpty ? 0 : 0.02),
                  ),
                  //show submit button
                  BlocBuilder<ExamCubit, ExamState>(
                    bloc: context.read<ExamCubit>(),
                    builder: (context, state) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * (0.3),
                        ),
                        child: CustomRoundedButton(
                          widthPercentage: MediaQuery.of(context).size.width,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: state is ExamFetchInProgress ? AppLocalization.of(context)!.getTranslatedValues(submittingButton)! : AppLocalization.of(context)!.getTranslatedValues(submitBtn)!,
                          radius: 10.0,
                          showBorder: false,
                          onTap: state is ExamFetchInProgress
                              ? () {}
                              : () {
                                  //
                                  if (textEditingController.text.trim() == widget.exam.examKey) {
                                    context.read<ExamCubit>().startExam(exam: widget.exam, userId: context.read<UserDetailsCubit>().getUserId());
                                  } else {
                                    setState(() {
                                      errorMessage = AppLocalization.of(context)!.getTranslatedValues(enterValidExamKey)!;
                                    });
                                  }
                                },
                          fontWeight: FontWeight.bold,
                          titleColor: Theme.of(context).backgroundColor,
                          height: 40.0,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.0125),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * (0.127),
                    ),
                    child: Divider(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * (0.127),
                      ),
                      child: Text(
                        "Exam Rules",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.0125),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * (0.125),
                    ),
                    child: Column(
                      children: examRules.map((e) => _buildExamRuleContainer(e)).toList(),
                    ),
                  ),

                  //
                  SizedBox(
                    height: MediaQuery.of(context).size.height * (0.05),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
