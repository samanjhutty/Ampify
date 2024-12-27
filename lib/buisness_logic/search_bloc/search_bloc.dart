import '../../data/data_models/search_model.dart';
import 'package:ampify/data/data_models/tracks_model.dart';
import 'package:ampify/data/repository/search_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/transformers.dart';

class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchEvent {}

class SearchCleared extends SearchEvent {}

class SearchTrigerred extends SearchEvent {}

class SearchInputChanged extends SearchEvent {
  final String query;
  const SearchInputChanged(this.query);

  SearchInputChanged copyWith(String? query) {
    return SearchInputChanged(query ?? this.query);
  }

  @override
  List<Object?> get props => [query, super.props];
}

class SearchState extends Equatable {
  final String query;
  final bool isError;
  final bool isLoading;
  final List<Track>? results;
  const SearchState(
      {required this.query,
      this.isError = false,
      required this.isLoading,
      this.results = const []});
  const SearchState.init()
      : query = '',
        isError = false,
        isLoading = false,
        results = null;

  SearchState copyWith(
      {String? query, bool? isError, bool? isLoading, List<Track>? results}) {
    return SearchState(
      query: query ?? this.query,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      results: results,
    );
  }

  @override
  List<Object?> get props => [query, isLoading, isError];
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState.init()) {
    on<SearchTrigerred>(_onSearchTrigerred, transformer: debounce(_duration));
    on<SearchInputChanged>(_onInputChanged);
    on<SearchInitial>(_onInit);
    on<SearchCleared>(_onSearchClear);
  }
  final SearchRepo _searchRepo = getIt();
  final _duration = const Duration(milliseconds: 800);
  final searchContr = TextEditingController();
  final focusNode = FocusNode();

  _onSearchTextChanged() => add(SearchInputChanged(searchContr.text));
  onSearchClear() => add(SearchCleared());

  _onInit(SearchInitial event, Emitter<SearchState> emit) {
    searchContr.addListener(_onSearchTextChanged);
  }

  void _onSearchClear(SearchCleared event, Emitter<SearchState> emit) {
    searchContr.clear();
    focusNode.unfocus();
    emit(state.copyWith(isLoading: false, results: null));
  }

  _onInputChanged(SearchInputChanged event, Emitter<SearchState> emit) async {
    if (state.query == event.query) return;
    if (searchContr.text.isEmpty) {
      emit(state.copyWith(isLoading: false, results: null, query: ''));
      return;
    }
    emit(state.copyWith(query: event.query, isLoading: true));
    add(SearchTrigerred());
  }

  _onSearchTrigerred(SearchTrigerred event, Emitter<SearchState> emit) async {
    if (searchContr.text.isEmpty) {
      emit(state.copyWith(isLoading: false, results: null, query: ''));
      return;
    }

    await _searchRepo.searchSongs(searchContr.text, limit: 20,
        onSuccess: (json) {
      final response = SearchModel.fromJson(json);
      final results = response.tracks?.items;
      emit(state.copyWith(isLoading: false, results: results));
    }, onError: (errorMap) {
      logPrint('search: $errorMap');
      emit(state.copyWith(isLoading: false, isError: true));
    });
  }
}
