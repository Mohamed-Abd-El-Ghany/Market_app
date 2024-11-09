import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test2/presentation/common/state_renderer/state_renderer.dart';
import '../../../app/constants.dart';
import '../../resources/strings_manager.dart';

// تعريف حالات التدفق
abstract class FlowState {
  StateRendererType getStateRendererType();

  String getMessage();
}

class LoadingState extends FlowState {
  final StateRendererType stateRendererType;
  final String? message;

  LoadingState(
      {required this.stateRendererType, this.message = AppStrings.loading});

  @override
  String getMessage() => message ?? AppStrings.loading.tr();

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

class ErrorState extends FlowState {
  final StateRendererType stateRendererType;
  final String message;
  bool hasAcknowledged; // Field to track acknowledgment

  ErrorState(this.stateRendererType, this.message,
      {this.hasAcknowledged = false});

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

class ContentState extends FlowState {
  ContentState();

  @override
  String getMessage() => Constants.empty;

  @override
  StateRendererType getStateRendererType() => StateRendererType.contentState;
}

class EmptyState extends FlowState {
  final String message;

  EmptyState(this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() =>
      StateRendererType.fullScreenEmptyState;
}

class SuccessState extends FlowState {
  final String message;

  SuccessState(this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => StateRendererType.popupSuccess;
}

extension FlowStateExtension on FlowState {
  Widget getScreenWidget(BuildContext context, Widget contentScreenWidget,
      Function retryActionFunction) {
    dismissDialog(context);

    switch (runtimeType) {
      case LoadingState:
        if (getStateRendererType() == StateRendererType.popupLoadingState) {
          showPopup(context, getStateRendererType(), getMessage(),
              retryActionFunction: retryActionFunction);
          return contentScreenWidget;
        } else {
          return StateRenderer(
            message: getMessage(),
            stateRendererType: getStateRendererType(),
            retryActionFunction: retryActionFunction,
          );
        }
      case ErrorState:
        final errorState = this as ErrorState; // Cast to access hasAcknowledged
        if (!errorState.hasAcknowledged) {
          if (getStateRendererType() == StateRendererType.popupErrorState) {
            if (!isCurrentDialogShowing(context)) {
              showPopup(
                context,
                getStateRendererType(),
                getMessage(),
                retryActionFunction: retryActionFunction,
              );
            }
            return contentScreenWidget; // Return current content
          } else {
            return StateRenderer(
              message: getMessage(),
              stateRendererType: getStateRendererType(),
              retryActionFunction: retryActionFunction,
            );
          }
        }
        return contentScreenWidget; // If already acknowledged, return content

      case EmptyState:
        return StateRenderer(
          stateRendererType: getStateRendererType(),
          message: getMessage(),
          retryActionFunction: () {},
        );
      case ContentState:
        return contentScreenWidget;
      case SuccessState:
        showPopup(context, StateRendererType.popupSuccess, getMessage(),
            title: AppStrings.success,
            retryActionFunction: retryActionFunction);
        return contentScreenWidget;
      default:
        return contentScreenWidget;
    }
  }

  bool isCurrentDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;

  void dismissDialog(BuildContext context) {
    if (isCurrentDialogShowing(context)) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  void showPopup(
      BuildContext context, StateRendererType stateRendererType, String message,
      {String title = Constants.empty, required Function retryActionFunction}) {
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) {
        showDialog(
          context: context,
          builder: (BuildContext context) => StateRenderer(
            stateRendererType: stateRendererType,
            message: message,
            title: title,
            retryActionFunction: () {
              if (this is ErrorState) {
                (this as ErrorState).hasAcknowledged =
                    true; // Mark error as acknowledged
              }
              dismissDialog(context); // Close the dialog
            },
          ),
        );
      },
    );
  }
}
