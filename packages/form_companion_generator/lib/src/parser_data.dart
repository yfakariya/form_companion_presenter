// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'parser_utilities.dart';

/// Represents a context information of parsing.
@sealed
class ParseContext {
  /// Gets a [Logger] to record trace log for debugging.
  final Logger logger;

  final List<_Scope> _scopes = [];

  final List<String> _warnings = [];

  /// Gets a recorded [PropertyDescriptorsBuilding] mapping,
  /// where keys are name of parameters and/or local variables
  /// which were target of property building operations.
  Map<String, PropertyDescriptorsBuilding> get buildings =>
      _scopes.isEmpty ? {} : _scopes.last.buildings;

  /// Gets a current local function lookup table.
  Map<String, FunctionDeclaration> get localFunctions =>
      _scopes.isEmpty ? {} : _scopes.last.localFunctions;

  /// If current executable is returned already, this property returns `true`.
  bool get isReturned => _scopes.last.isReturned;

  PropertyDescriptorsBuilding? _returnValue;

  /// Gets a current return value, which is anonymous `PropertyDescritporsBuilder`
  /// variable which may have been done any propeprty building operations.
  ///
  /// This value will be cleared when [endFunctionBody] will be called.
  PropertyDescriptorsBuilding? get returnValue => _returnValue;

  /// Gets a detected anonymous `PropertyDescritporsBuilder` variable
  /// which is directly passed to `initializeCompanionMixin` method as
  /// its single and unique argument.
  ///
  /// This value will never be cleared.
  PropertyDescriptorsBuilding? initializeCompanionMixinArgument;

  /// Initialize a new [ParseContext] instance.
  ParseContext(this.logger);

  /// Marks that current executable is returned.
  ///
  /// Caller must specify returning value when the type of the expression
  /// is `PropertyDescriptorsBuilder` type via [returnValue] parameter.
  void markAsReturned([PropertyDescriptorsBuilding? returnValue]) {
    _scopes.last.isReturned = true;
    _returnValue = returnValue;
  }

  /// Adds specified warning message as global warning.
  void addGlobalWarning(String warning) {
    _warnings.add(warning);
  }

  /// Coordinates internal information to handle beginning of new block scope.
  ///
  /// [localFunctions] is a local function lookup table from outer scope,
  /// and will be copied.
  void beginBlock(Map<String, FunctionDeclaration> localFunctions) {
    final newScope = _scopes.isEmpty
        ? _Scope({}, {})
        : _Scope(_scopes.last.buildings, _scopes.last.localFunctions);
    newScope.localFunctions.addAll(localFunctions);
    _scopes.add(newScope);
  }

  /// Coordinates internal information to handle end of current block scope.
  void endBlock() {
    _scopes.removeLast();
  }

  /// Coordinates internal information to handle beginning of new function body.
  ///
  /// In [arguments], `null` will be treated same as an empty map.
  void beginFunctionBody(Map<String, PropertyDescriptorsBuilding>? arguments) {
    _scopes.add(_Scope(arguments ?? {}, {}));
  }

  /// Coordinates internal information to handle end of current function body.
  void endFunctionBody() {
    _scopes.removeLast();
    _returnValue = null;
  }
}

/// A scope of [ParseContext].
class _Scope {
  final Map<String, PropertyDescriptorsBuilding> buildings;
  final Map<String, FunctionDeclaration> localFunctions;
  bool isReturned = false;

  _Scope(Map<String, PropertyDescriptorsBuilding> outerBuildings,
      Map<String, FunctionDeclaration> outerLocalFunctions)
      : buildings = Map.from(outerBuildings),
        localFunctions = Map.from(outerLocalFunctions);
}

/// Represents a series of property building operations for specified variable.
@sealed
class PropertyDescriptorsBuilding {
  /// Gets a name of variable which is operated in.
  final String variableName;

  final List<MethodInvocation> _buildings;

  /// `true` if this variable is assigned to non-local variable.
  bool _isMutable = false;

  /// Gets a series of property building operations in order.
  Iterable<MethodInvocation> get buildings => _buildings;

  /// Effiently gets a value  whether [buildings] is empty or not.
  bool get isEmpty => _buildings.isEmpty;

  PropertyDescriptorsBuilding._(
      this.variableName, this._buildings, this._isMutable);

  /// Creates new [PropertyDescriptorsBuilding] for `PropertyDescriptorsBuilder`
  /// instantiation.
  PropertyDescriptorsBuilding.begin() : this._('', [], false);

  /// Creates new [PropertyDescriptorsBuilding] for assignment for some variable
  /// which name is [newVariableName].
  PropertyDescriptorsBuilding chain(String newVariableName) {
    return PropertyDescriptorsBuilding._(
        newVariableName, _buildings, _isMutable);
  }

  /// Adds a detected property building operation,
  /// that is, any method call for `PropertyDescriptorsBuilder` instance.
  ///
  /// [contextElement] is needed for kindful error reporting after.
  ///
  /// If the operation is attempted to shared instance,
  /// [InvalidGenerationSourceError] will be thrown.
  void add(MethodInvocation invocation, Element contextElement) {
    if (_isMutable) {
      throwError(
        message:
            'Modification of shared $pdbTypeName object is detected at ${getNodeLocation(invocation, contextElement)}.',
        todo:
            'Do not define extra properties to $pdbTypeName when it is declared as fields or top level variables because $pdbTypeName is mutable object.',
        element: contextElement,
      );
    }

    _buildings.add(invocation);
  }

  /// Adds a series of detected property building operation,
  /// that is, any method calls for `PropertyDescriptorsBuilder` instance.
  ///
  /// This method is designed for cascading.
  ///
  /// If the operation is attempted to shared instance,
  /// [InvalidGenerationSourceError] will be thrown.
  void addAll(Iterable<MethodInvocation> invocations, Element contextElement) {
    for (final invocation in invocations) {
      add(invocation, contextElement);
    }
  }

  /// Marks this `PropertyDescriptorsBuilder` instance is assigned to shared variable
  /// including field or top level variable.
  void markAsMutable() {
    _isMutable = true;
  }
}
