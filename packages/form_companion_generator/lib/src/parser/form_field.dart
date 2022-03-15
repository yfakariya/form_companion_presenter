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
  final fieldTypeName = _determineFormFieldTypeName(
    context,
    property.type,
    property.preferredFieldType,
    isFormBuilder: isFormBuilder,
  );
  context.logger.fine(
    'Use $fieldTypeName for property name: ${property.name}, type: ${property.type}, preferredFieldType: ${property.preferredFieldType}',
  );
  final fieldType =
      context.formFieldLocator.resolveFormFieldType(fieldTypeName);
  ConstructorDeclaration? fieldConstructor;
  TypeInstantiationContext? instantiationContext;
  if (fieldType != null) {
    final constructorElement =
        _findFormFieldConstructor(fieldType, property.warnings);
    if (constructorElement != null) {
      fieldConstructor = await context.nodeProvider
          .getElementDeclarationAsync<ConstructorDeclaration>(
        constructorElement,
      );
    }

    instantiationContext = TypeInstantiationContext.create(
      context.nodeProvider,
      property,
      fieldType,
    );
  }

  return PropertyAndFormFieldDefinition(
    property: property,
    fieldType: fieldType,
    fieldTypeName: fieldTypeName,
    fieldConstructor: fieldConstructor,
    instantiationContext: instantiationContext,
  );
}

String _determineFormFieldTypeName(
  ParseContext context,
  InterfaceType propertyType,
  String? preferredFieldType, {
  required bool isFormBuilder,
}) {
  if (preferredFieldType != null) {
    return preferredFieldType;
  } else {
    if (context.typeSystem.isAssignableTo(
      propertyType,
      context.typeProvider.enumType!,
    )) {
      return isFormBuilder
          ? _enumFormBuilderFieldType
          : _enumVanillaFormFieldType;
    }

    // Use element name to ignore type arguments here.
    final propertyTypeName = propertyType.element.name;
    if (isFormBuilder) {
      return _predefinedFormBuilderFieldTypes[propertyTypeName] ??
          _defaultFormBuilderFieldType;
    } else {
      return _predefinedVanillaFormFieldTypes[propertyTypeName] ??
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

final _defaultFormBuilderFieldType = 'FormBuilderTextField';

final _defaultVanillaFormFieldType = 'TextFormField';

final _enumFormBuilderFieldType = 'FormBuilderDropdown';

final _enumVanillaFormFieldType = 'DropdownButtonFormField';

final _predefinedFormBuilderFieldTypes = {
  'bool': 'FormBuilderSwitch',
  'DateTime': 'FormBuilderDateTimePicker',
  'DateTimeRange': 'FormBuilderDateRangePicker',
  'List': 'FormBuilderFilterChip',
  'RangeValues': 'FormBuilderRangeSlider',
};

final _predefinedVanillaFormFieldTypes = {
  'bool': 'DropdownButtonFormField',
};
