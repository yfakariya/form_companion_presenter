// See LICENCE file in the root.

part of '../parser.dart';

// Defines resolveFormField and its sub functions.

/// Resolves form field information from [property] and set up them
/// as [PropertyAndFormFieldDefinition].
@visibleForTesting
FutureOr<PropertyAndFormFieldDefinition> resolveFormFieldAsync(
  ParseContext context,
  PropertyDefinition property, {
  required bool isFormBuilder,
}) async {
  final formFieldRawTypeName = _determineFormFieldTypeName(
    context,
    property.fieldType,
    property.preferredFormFieldType,
    isFormBuilder: isFormBuilder,
  );
  context.logger.fine(
    'Use $formFieldRawTypeName for property name: ${property.name}, '
    'fieldValueType: ${property.fieldType}, '
    'preferredFormFieldType: ${property.preferredFormFieldType}',
  );

  final preferredFieldType =
      property.preferredFormFieldType?.maybeAsInterfaceType;

  final formFieldType = preferredFieldType ??
      context.formFieldLocator.resolveFormFieldType(
        formFieldRawTypeName,
      );
  ConstructorDeclaration? fieldConstructor;
  TypeInstantiationContext? instantiationContext;
  if (formFieldType != null) {
    final constructorElement =
        _findFormFieldConstructor(formFieldType, property.warnings);
    if (constructorElement != null) {
      fieldConstructor = await context.nodeProvider
          .getElementDeclarationAsync<ConstructorDeclaration>(
        constructorElement,
      );
    }

    instantiationContext = TypeInstantiationContext.create(
      context.nodeProvider,
      property,
      formFieldType,
      context.logger,
    );
  }

  return PropertyAndFormFieldDefinition(
    property: property,
    formFieldType: formFieldType,
    formFieldTypeName: formFieldRawTypeName,
    formFieldConstructor: fieldConstructor,
    instantiationContext: instantiationContext,
  );
}

String _determineFormFieldTypeName(
  ParseContext context,
  GenericInterfaceType fieldValueType,
  GenericInterfaceType? preferredFormFieldType, {
  required bool isFormBuilder,
}) {
  if (preferredFormFieldType != null) {
    return preferredFormFieldType.rawTypeName;
  } else {
    if (context.typeSystem.isAssignableTo(
      fieldValueType.rawType,
      context.typeProvider.enumType!,
    )) {
      return isFormBuilder
          ? _enumFormBuilderFieldType
          : _enumVanillaFormFieldType;
    }

    // Use element name to ignore type arguments here.
    final fieldValueTypeName = fieldValueType.rawTypeName;
    if (isFormBuilder) {
      return _predefinedFormBuilderFieldTypes[fieldValueTypeName] ??
          _defaultFormBuilderFieldType;
    } else {
      return _predefinedVanillaFormFieldTypes[fieldValueTypeName] ??
          _defaultVanillaFormFieldType;
    }
  }
}

ConstructorElement? _findFormFieldConstructor(
  InterfaceType formFieldType,
  List<String> warnings,
) {
  final normalConstructors =
      formFieldType.element.constructors.where((c) => c.isPublic).toList();
  if (normalConstructors.length != 1) {
    warnings.add(
      "Failed to determine calling constructor because '$formFieldType' has ${normalConstructors.length} non-factory constructors.",
    );
    return null;
  }

  return normalConstructors.single;
}

final _defaultFormBuilderFieldType = 'FormBuilderField';

final _defaultVanillaFormFieldType = 'FormField';

final _enumFormBuilderFieldType = 'FormBuilderDropdown';

final _enumVanillaFormFieldType = 'DropdownButtonFormField';

final _predefinedFormBuilderFieldTypes = {
  'bool': 'FormBuilderSwitch',
  'DateTime': 'FormBuilderDateTimePicker',
  'DateTimeRange': 'FormBuilderDateRangePicker',
  'List': 'FormBuilderFilterChip',
  'RangeValues': 'FormBuilderRangeSlider',
  'String': 'FormBuilderTextField',
};

final _predefinedVanillaFormFieldTypes = {
  'bool': 'DropdownButtonFormField',
  'String': 'TextFormField',
};
