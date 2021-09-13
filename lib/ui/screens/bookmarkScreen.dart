import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

import 'package:flutterquiz/ui/widgets/customListTile.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  void openBottomSheet(BuildContext context, Question question) {
    String? correctAnswer = question.answerOptions![question.answerOptions!.indexWhere((element) => element.id == question.correctAnswerOptionId)].title;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        backgroundColor: Theme.of(context).backgroundColor,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.9),
                  child: Text(
                    "${question.question}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.9),
                  child: Text(
                    AppLocalization.of(context)!.getTranslatedValues("yourAnsLbl")! + ":" + " ${context.read<BookmarkCubit>().getSubmittedAnswerForQuestion(question.id)}",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0, color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 7.5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.9),
                  child: Text(
                    AppLocalization.of(context)!.getTranslatedValues("correctAndLbl")! + ":" + " $correctAnswer",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0, color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkCubit = context.read<BookmarkCubit>();

    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(title: AppLocalization.of(context)!.getTranslatedValues("bookmarkLbl")!),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: BlocBuilder<BookmarkCubit, BookmarkState>(builder: (context, state) {
                if (state is BookmarkFetchSuccess) {
                  if (state.questions.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalization.of(context)!.getTranslatedValues("noBookmarkQueLbl")!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsetsDirectional.only(top: 25.0, start: MediaQuery.of(context).size.width * (0.075), end: MediaQuery.of(context).size.width * (0.075), bottom: 100),
                    itemBuilder: (context, index) {
                      Question question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarekd question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (context) => UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) => BlocConsumer<UpdateBookmarkCubit, UpdateBookmarkState>(
                            bloc: context.read<UpdateBookmarkCubit>(),
                            listener: (context, state) {
                              if (state is UpdateBookmarkSuccess) {
                                bookmarkCubit.removeBookmarkQuestion(question.id);
                              }
                              if (state is UpdateBookmarkFailure) {
                                UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(updateBookmarkFailureCode))!, context, false);
                              }
                            },
                            builder: (context, state) {
                              return GestureDetector(
                                onTap: () {
                                  openBottomSheet(context, question);
                                },
                                child: CustomListTile(
                                  opacity: state is UpdateBookmarkInProgress ? 0.5 : 1.0,
                                  trailingButtonOnTap: state is UpdateBookmarkInProgress
                                      ? () {}
                                      : () {
                                          context.read<UpdateBookmarkCubit>().updateBookmark(context.read<UserDetailsCubit>().getUserId(), question.id!, "0");
                                        },
                                  subtitle: AppLocalization.of(context)!.getTranslatedValues("yourAnsLbl")! + ":" + " ${context.read<BookmarkCubit>().getSubmittedAnswerForQuestion(question.id)}",
                                  title: question.question,
                                  leadingChild: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: Theme.of(context).backgroundColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                  );
                }
                if (state is BookmarkFetchFailure) {
                  return ErrorContainer(
                    errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)),
                    showErrorImage: true,
                    onTapRetry: () {
                      context.read<BookmarkCubit>().getBookmark(context.read<UserDetailsCubit>().getUserId());
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * (0.16)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 25.0),
              child: BlocBuilder<BookmarkCubit, BookmarkState>(
                builder: (context, state) {
                  if (state is BookmarkFetchSuccess && state.questions.isNotEmpty) {
                    return CustomRoundedButton(
                      widthPercentage: 0.85,
                      backgroundColor: Theme.of(context).primaryColor,
                      buttonTitle: AppLocalization.of(context)!.getTranslatedValues("playBookmarkBtn")!,
                      radius: 5.0,
                      showBorder: false,
                      fontWeight: FontWeight.w500,
                      height: 50.0,
                      titleColor: Theme.of(context).backgroundColor,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.bookmarkQuiz,
                        );
                      },
                      elevation: 6.5,
                      textSize: 17.0,
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
