import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class BookmarkButton extends StatelessWidget {
  final Question question;
  final Color? bookmarkButtonColor;
  final Color? bookmarkFillColor;

  const BookmarkButton({Key? key, required this.question, this.bookmarkFillColor, this.bookmarkButtonColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookmarkCubit = context.read<BookmarkCubit>();
    final updateBookmarkcubit = context.read<UpdateBookmarkCubit>();

    return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
      bloc: updateBookmarkcubit,
      listener: (context, state) {
        //if failed to update bookmark status
        if (state is UpdateBookmarkFailure) {
          //remove bookmark question
          if (state.failedStatus == "0") {
            //if unable to remove question from bookmark then add question
            //add again
            bookmarkCubit.addBookmarkQuestion(question);
          } else {
            //remove again
            //if unable to add question to bookmark then remove question
            bookmarkCubit.removeBookmarkQuestion(question.id);
          }
          UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(updateBookmarkFailureCode))!, context, false);
        }
        if (state is UpdateBookmarkSuccess) {
          print("Success");
        }
      },
      child: BlocBuilder<BookmarkCubit, BookmarkState>(
        bloc: bookmarkCubit,
        builder: (context, state) {
          if (state is BookmarkFetchSuccess) {
            return IconButton(
              onPressed: () {
                if (bookmarkCubit.hasQuestionBookmarked(question.id)) {
                  //remove
                  bookmarkCubit.removeBookmarkQuestion(question.id);
                  updateBookmarkcubit.updateBookmark(context.read<UserDetailsCubit>().getUserId(), question.id!, "0");
                } else {
                  //add
                  bookmarkCubit.addBookmarkQuestion(question);
                  updateBookmarkcubit.updateBookmark(context.read<UserDetailsCubit>().getUserId(), question.id!, "1");
                }
              },
              icon: bookmarkCubit.hasQuestionBookmarked(question.id)
                  ? Icon(
                      CupertinoIcons.bookmark_fill,
                      color: bookmarkFillColor ?? Theme.of(context).colorScheme.secondary,
                      size: 20,
                    )
                  : Icon(
                      CupertinoIcons.bookmark,
                      color: bookmarkButtonColor ?? Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
            );
          }
          if (state is BookmarkFetchFailure) {
            return Container();
          }

          return Container();
        },
      ),
    );
  }
}
