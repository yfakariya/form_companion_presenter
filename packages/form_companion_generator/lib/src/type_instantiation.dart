// See LICENCE file in the root.

import 'package:analyzer/dart/element/type.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'model.dart';

/// A context information holder of type instantiaion.
@sealed
class TypeInstantiationContext {
  final Map<String, Map<String, GenericType>> _typeArgumentsMappings;

  TypeInstantiationContext._(
    this._typeArgumentsMappings,
  );

  /// Creates a new [TypeInstantiationContext] instance
  /// for the [PropertyDefinition].
  ///
  /// Note that [formFieldType] must be fully instantiated [InterfaceType]
  /// if it is specified as `preferredFieldType` because it may have any
  /// type argument(s) for its super which cannot be lead from
  /// [PropertyDefinition.fieldType].
  /// For example, the second type argument `bool` of
  /// `Derived<T> extends Super<T, bool>` cannot be lead from the `fieldType`.
  factory TypeInstantiationContext.create(
    PropertyDefinition property,
    InterfaceType formFieldType,
    Logger logger,
  ) {
    Iterable<InterfaceType> buildTypeChain(InterfaceType leafType) sync* {
      // derived to super.
      for (var type = leafType;
          type.element.name !=
              'FormField'; // We must erase type argument information chain from leaf here
          // to traverse mapping information.
          type = type.superclass!.element.thisType) {
        yield type;
        assert(type.superclass != null, "type.superclass of '$type' is null.");
      }
    }

    void buildLeafTypeMap(
      InterfaceType leafType,
      Map<String, Map<String, GenericType>> mapping,
    ) {
      // Follow-up for type arguments for leaf type which is not passed to the ancestor here.
      final mappingOfLeafType =
          mapping.putIfAbsent(leafType.element.name, () => {});
      final typeParametersOfThis = leafType.element.thisType.typeArguments;
      final typeArgumentsToThis = leafType.typeArguments;

      for (var i = 0; i < leafType.typeArguments.length; i++) {
        mappingOfLeafType.putIfAbsent(
          typeParametersOfThis[i].element!.name!,
          () => GenericType.fromDartType(
            typeArgumentsToThis[i],
            leafType.element,
          ),
        );
      }
    }

    final typeChain = buildTypeChain(formFieldType).toList();

    final mapping = <String, Map<String, GenericType>>{};
    mapping['FormField'] = {'T': property.fieldType};

    // super to derived
    for (final type in typeChain.reversed) {
      _buildTypeArgumentMappings(type, mapping);
    }

    buildLeafTypeMap(formFieldType, mapping);

    logger.finer(
      "Create type arguments mapping between field type arguments of '$formFieldType': $mapping",
    );
    return TypeInstantiationContext._(mapping);
  }

  // In this method, we just know following:
  //   1. Generic type ARGUMENT to super type from current type.
  //      For example, `List<T>` for `T` of super type Base<T>.
  //      We can get them via `superType.typeArguments` because we erased
  //      (potentially partial) instantiation in the type chain.
  //   2. Real type to be passed to the super type.
  //      For root type (`FormField<T>`), this is a field type of the property.
  //      For other types, we can retrieve it from building mappings with
  //      super type's type parameters.
  //      We can simply get them via `superType.element.thisType.typeArguments`.
  // We can compare types between the 1 and 2 now, so we can get mapping between
  // type PARAMETER of the current type and REAL type of the current type.
  //
  // In addition, we can build mapping of super type parameter and type argument
  // which is not passed to ancestor.

  static void _buildTypeArgumentMappings(
    InterfaceType currentType,
    Map<String, Map<String, GenericType>> mapping,
  ) {
    final superType = currentType.superclass!;
    final typeParametersOfSuper = superType.element.thisType.typeArguments;
    final typeArgumentsToSuper = superType.typeArguments;
    assert(typeArgumentsToSuper.length == typeParametersOfSuper.length);

    for (var i = 0; i < typeParametersOfSuper.length; i++) {
      final realTypeArgumentToSuper = mapping[superType.element.name]
          ?[typeParametersOfSuper[i].element?.name];
      if (realTypeArgumentToSuper != null) {
        // We can get mapping between
        // type parameter of the current type and real type of the current type.
        _buildTypeArgumentMapping(
          currentType,
          typeArgumentsToSuper[i],
          realTypeArgumentToSuper,
          mapping,
        );
      } else {
        // We can build mapping of super type parameter and type argument
        // which is not passed to ancestor here,
        // because we know the actual type from the type argument.
        final mappingOfSuperType =
            mapping.putIfAbsent(superType.element.name, () => {});
        mappingOfSuperType[typeParametersOfSuper[i].element!.name!] =
            GenericType.fromDartType(
          typeArgumentsToSuper[i],
          superType.element,
        );
      }
    }
  }

  static void _buildTypeArgumentMapping(
    InterfaceType currentType,
    DartType template,
    GenericType instance,
    Map<String, Map<String, GenericType>> mapping,
  ) {
    if (template is TypeParameterType) {
      // Map `Foo` to `T` here.
      final mappingForCurrentType =
          mapping.putIfAbsent(currentType.element.name, () => {});
      mappingForCurrentType[template.getDisplayString(withNullability: false)] =
          instance;
      return;
    }

    // Start generic type comparsion like `Foo<T> extends FormField<List<T>>`

    final realTemplate = template.alias?.element.aliasedType ?? template;

    if (realTemplate is ParameterizedType) {
      // Do structural mapping here
      assert(
        realTemplate.element!.name == instance.rawType.element!.name,
        '${realTemplate.element!.name} != ${instance.rawType.element!.name} in $currentType', // coverage:ignore-line
      );
      assert(
        realTemplate.typeArguments.length == instance.typeArguments.length,
        'Arity mismatch between $realTemplate and $instance', // coverage:ignore-line
      );

      if (realTemplate.typeArguments.isEmpty) {
        // Nothing to do.
        // The mapping should be resolved in derviced type or final step.
        return;
      }

      for (var i = 0; i < realTemplate.typeArguments.length; i++) {
        _buildTypeArgumentMapping(
          currentType,
          realTemplate.typeArguments[i],
          instance.typeArguments[i],
          mapping,
        );
      }
      return;
    }

    if (realTemplate is FunctionType) {
      assert(
        instance is GenericFunctionType,
        '$instance is not GenericFunctionType', // coverage:ignore-line
      );
      final functionTypeArgument = instance as GenericFunctionType;
      assert(
        realTemplate.parameters.length ==
            functionTypeArgument.parameterTypes.length,
        'Parameter count mismatch between $realTemplate and $functionTypeArgument', // coverage:ignore-line
      );

      _buildTypeArgumentMapping(
        currentType,
        realTemplate.returnType,
        functionTypeArgument.returnType,
        mapping,
      );

      final functionTypeArgumentParameterTypes =
          functionTypeArgument.parameterTypes.toList();

      for (var i = 0; i < realTemplate.parameters.length; i++) {
        _buildTypeArgumentMapping(
          currentType,
          realTemplate.parameters[i].type,
          functionTypeArgumentParameterTypes[i],
          mapping,
        );
      }

      return;
    }

    // Do nothing for NeverType, DynamicType, and VoidType.
  }

  /// Gets a mapped type string which was specified as type argument.
  /// If the [mayBeTypeParameter] is not a type parameter,
  /// then its value will be returned.
  ///
  /// This method is a core of type instantiation.
  String getMappedType(
    String contextTypeName,
    String mayBeTypeParameter,
  ) =>
      _typeArgumentsMappings[contextTypeName]?[mayBeTypeParameter]
          ?.getDisplayString(withNullability: true) ??
      mayBeTypeParameter;

  /// Returns `true` if this instance can return a mapped type string
  /// which was specified as type argument.
  bool isMapped(
    String contextTypeName,
    String mayBeTypeParameter,
  ) =>
      _typeArgumentsMappings[contextTypeName]
          ?.containsKey(mayBeTypeParameter) ??
      false;
}
