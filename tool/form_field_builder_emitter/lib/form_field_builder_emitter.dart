// See LICENCE file in the root.

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as path;

/// Emits form field builder code.
///
/// ### Parameters
/// * [libraryRootPath] Path to library source directory of pub cache. The library must include target form field classes.
/// * [targetFiles] Specify target library source files without their extensions (.dart).
/// * [targetClassNames] Specify target class names.
/// * [headers] Specify custom source file header lines such as copyright notice and ignore-file: statement without their prefix ('//').
/// * [importPackages] Specify importing package pathes without their prefix ('import package:').
/// * [outputFilePath] Specify output file path which is relative to the package root. If you specify `null`, the [stdout] will be used.
Future<void> emit(
  String libraryRootPath,
  Set<String> targetFiles,
  Set<String> targetClassNames,
  Iterable<String> headers,
  Iterable<String> importPackages,
  String? outputFilePath, [
  String? Function(String?)? typeNameAdjuster,
]) async {
  final collection = AnalysisContextCollection(
    includedPaths: targetFiles
        .map((e) => path.canonicalize('$libraryRootPath/$e.dart'))
        .toList(),
  );

  final visitor =
      _ConstructorParametersScanner(targetClassNames, typeNameAdjuster);

  for (final context in collection.contexts) {
    stderr.writeln('Analyzing ${context.contextRoot.root.path} ...');

    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (!filePath.endsWith('.dart')) {
        continue;
      }

      final library = await context.currentSession.getResolvedLibrary(filePath);
      if (library is! ResolvedLibraryResult) {
        continue;
      }

      for (final unit in library.units) {
        stderr.writeln('\tUnit: ${unit.path}');
        for (final decl in unit.unit.declarations) {
          decl.accept(visitor);
        }
      }
    }
  }

  final sink = outputFilePath != null
      ? File(path.canonicalize(outputFilePath)).openWrite()
      : stdout;
  try {
    if (outputFilePath != null) {
      stderr.writeln('Writing outputs to $outputFilePath');
    } else {
      stderr.writeln('Writing outputs to STDOUT:');
    }

    _emitFormFieldBuilder(visitor.classes, headers, importPackages, sink);
    await sink.flush();
  } finally {
    await sink.close();
  }
}

void _emitFormFieldBuilder(
  List<_ClassSpec> specs,
  Iterable<String> headers,
  Iterable<String> importPackages,
  StringSink sink,
) {
  var hasHeader = false;
  for (final header in headers) {
    sink.writeln('// $header');
    hasHeader = true;
  }

  if (hasHeader) {
    sink.writeln();
  }

  for (final importPackage in importPackages) {
    if (importPackage.isEmpty) {
      sink.writeln();
    } else {
      sink.writeln('$importPackage;');
    }
  }
  for (final spec in specs) {
    final builderTypeName = spec.typeParameters.isEmpty
        ? '${spec.name}Builder'
        : '${spec.name}Builder<${spec.typeParameters.join(', ')}>';
    final formFieldTypeName = spec.typeParameters.isEmpty
        ? spec.name
        : '${spec.name}<${spec.typeParameters.map((e) => e.name).join(' ,')}>';

    sink
      ..writeln()
      ..writeln('/// A builder for [${spec.name}].')
      ..writeln('@sealed')
      ..writeln('class $builderTypeName {');

    for (final parameter in spec.parameters) {
      _emitProperty(parameter, sink);
    }

    sink
      ..writeln()
      ..writeln('  /// Build [${spec.name}] instance from this builder.')
      ..writeln('  $formFieldTypeName build() {');
    for (final requiredParameter
        in spec.parameters.where((p) => p.isRequired)) {
      sink.writeln(
        '    assert(${requiredParameter.name} != null, "\'${requiredParameter.name}\' is required.");',
      );
    }
    sink.writeln('    return $formFieldTypeName(');

    for (final parameter in spec.parameters) {
      if (parameter.isRequired) {
        // Emit as non-null forcing.
        sink.writeln(
          '      ${parameter.name}: ${parameter.name}!,',
        );
      } else {
        sink.writeln(
          '      ${parameter.name}: ${parameter.name},',
        );
      }
    }

    sink
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}');
  }
}

void _emitProperty(_ParameterSpec parameter, StringSink sink) {
  if (parameter.docComment != null) {
    sink.writeln('  /// ${parameter.docComment}');
  }

  if (parameter.isRequired) {
    // Define fields as nullable.
    sink.write(
      '  ${parameter.type}? ${parameter.name}',
    );
  } else {
    sink.write(
      '  ${parameter.type} ${parameter.name}',
    );
  }

  if (parameter.defaultValue != null) {
    sink.write(' = ${parameter.defaultValue}');
  }

  sink.writeln(';');
}

class _ClassSpec {
  final String name;
  final List<TypeParameter> typeParameters;
  final List<_ParameterSpec> parameters;

  _ClassSpec(this.name, this.typeParameters, this.parameters);
}

class _ParameterSpec {
  final String name;
  final String? type;
  final String? defaultValue;
  final String? docComment;

  bool get isRequired =>
      defaultValue == null && !(type?.endsWith('?') ?? false);

  _ParameterSpec(this.name, this.type, this.defaultValue, this.docComment);
}

class _FieldSpec {
  final String name;
  final String type;
  final String? docComment;

  _FieldSpec(this.name, this.type, this.docComment);
}

class _ConstructorParametersScanner extends RecursiveAstVisitor<void> {
  final Set<String> _targets;
  final List<_ParameterSpec> _parameters = [];
  final Map<String, _FieldSpec> _fields = {};
  final String? Function(String?)? _typeNameAdjuster;

  final List<_ClassSpec> classes = [];

  _ConstructorParametersScanner(this._targets, this._typeNameAdjuster);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!_targets.contains(node.name.name)) {
      return;
    }

    assert(_parameters.isEmpty);
    assert(_fields.isEmpty);

    super.visitClassDeclaration(node);
    classes.add(
      _ClassSpec(
        node.name.name,
        node.typeParameters?.typeParameters.toList() ?? [],
        _parameters
            .map(
              (e) => _ParameterSpec(
                e.name,
                e.type ?? _fields[e.name]?.type,
                e.defaultValue,
                e.docComment ?? _fields[e.name]?.docComment,
              ),
            )
            .toList(),
      ),
    );
    _parameters.clear();
    _fields.clear();
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    for (final parameter in node.parameters.parameters) {
      if (parameter.metadata.any(
          (a) => a.name.name == 'deprecated' || a.name.name == 'Deprecated')) {
        stderr
            .writeln(' Skip ${parameter.identifier} because it is deprecated.');
        continue;
      }

      // ignore: avoid_multiple_declarations_per_line
      String? name, type, docComment, defaultValue;
      for (final c in parameter.childEntities) {
        if (c is SimpleFormalParameter) {
          name = c.identifier.toString();
          type = _getTypeName(c.type, _typeNameAdjuster);
          docComment = c.documentationComment?.toString();
        } else if (c is FieldFormalParameter) {
          name = c.identifier.toString();
          type = _getTypeName(c.type, _typeNameAdjuster);
          docComment = c.documentationComment?.toString();
        } else {
          defaultValue = c.toString();
        }
      }

      _parameters.add(
        _ParameterSpec(
          name!,
          type,
          defaultValue,
          docComment,
        ),
      );
    }

    super.visitConstructorDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final field in node.fields.variables) {
      _fields[field.name.toString()] = _FieldSpec(
        field.name.toString(),
        _getTypeName(node.fields.type, _typeNameAdjuster)!,
        node.fields.documentationComment?.toString(),
      );
    }
    super.visitFieldDeclaration(node);
  }
}

String? _getTypeName(
  TypeAnnotation? typeAnnotation,
  String? Function(String?)? typeNameAdjuster,
) =>
    typeNameAdjuster != null
        ? typeNameAdjuster(typeAnnotation?.toString())
        : typeAnnotation?.toString();