// lib/views/reports/logic/report_state.dart

import 'package:equatable/equatable.dart';
import '../data/models/report.dart';
import '../data/models/my_report.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportCreating extends ReportState {}

class ReportCreated extends ReportState {
  final Report report;

  const ReportCreated({required this.report});

  @override
  List<Object?> get props => [report];
}

class ReportFailure extends ReportState {
  final String error;

  const ReportFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// My Reports States
class MyReportsLoading extends ReportState {}

class MyReportsLoaded extends ReportState {
  final List<MyReport> reports;
  final int totalElements;
  final bool hasMore;
  final int currentPage;

  const MyReportsLoaded({
    required this.reports,
    required this.totalElements,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [reports, totalElements, hasMore, currentPage];

  MyReportsLoaded copyWith({
    List<MyReport>? reports,
    int? totalElements,
    bool? hasMore,
    int? currentPage,
  }) {
    return MyReportsLoaded(
      reports: reports ?? this.reports,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class MyReportsEmpty extends ReportState {}

class MyReportsError extends ReportState {
  final String message;

  const MyReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}
