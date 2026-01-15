import 'package:flutter/material.dart';
import 'package:lando/features/home/home_repository.dart';
import 'package:lando/features/home/query/query_bloc.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/network/api_client.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  late final QueryBloc _bloc;
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bloc = QueryBloc(HomeRepository(ApiClient()));
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    // Auto focus and trigger search if initial query is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _bloc.add(QuerySearchSubmitted(widget.initialQuery!));
      }
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(l10n.translation),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search TextField
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: l10n.translation,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _bloc.add(QuerySearchSubmitted(value.trim()));
                  }
                },
              ),
              const SizedBox(height: 24.0),
              // Results area
              Expanded(
                child: StreamBuilder<QueryState>(
                  stream: _bloc.stream,
                  initialData: _bloc.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? _bloc.state;

                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                if (state.query.isNotEmpty) {
                                  _bloc.add(QuerySearchSubmitted(state.query));
                                }
                              },
                              child: Text(l10n.translation),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.result.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              l10n.translation,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SelectableText(
                          state.result,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
