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

  // We know all pre-defined FormField types do not have generic types
  // which cannot be lead from field type, but preferredFieldType may have
  // such type arguments. So, we must pass to fully instantiated InterfaceType to
  // `TypeInstantiationContext.create` below.
  assert(
    preferredFieldType == null || isInstantiated(preferredFieldType),
    // coverage:ignore-line
    "'$preferredFieldType' is not closed generic.",
  );

  final formFieldType = preferredFieldType ??
      context.formFieldLocator.resolveFormFieldType(
        formFieldRawTypeName,
      );
  List<FormFieldConstructorDefinition>? fieldConstructors;
  TypeInstantiationContext? instantiationContext;
  if (formFieldType != null) {
    fieldConstructors =
        await formFieldType.element.constructors.where((c) => c.isPublic).map(
      (e) async {
        final declaration = await context.nodeProvider
            .getElementDeclarationAsync<ConstructorDeclaration>(
          e,
        );
        return FormFieldConstructorDefinition(
          declaration,
          await ArgumentsHandler.createAsync(
            context.languageVersion,
            declaration,
            property,
            context.nodeProvider,
            context.config,
            isFormBuilder: isFormBuilder,
          ),
        );
      },
    ).toListAsync();

    instantiationContext = TypeInstantiationContext.create(
      property,
      formFieldType,
      context.logger,
    );
  }

  return PropertyAndFormFieldDefinition(
    property: property,
    formFieldType: formFieldType,
    formFieldTypeName: formFieldRawTypeName,
    formFieldConstructors: fieldConstructors ?? [],
    instantiationContext: instantiationContext,
  );
}

String _determineFormFieldTypeName(
  ParseContext context,
  GenericType fieldValueType,
  GenericType? preferredFormFieldType, {
  required bool isFormBuilder,
}) {
  if (preferredFormFieldType != null) {
    return preferredFormFieldType.rawType.element!.name!;
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
    final fieldValueTypeName = fieldValueType.rawType.element?.name;
    if (isFormBuilder) {
      return _predefinedFormBuilderFieldTypes[fieldValueTypeName] ??
          _defaultFormBuilderFieldType;
    } else {
      return _predefinedVanillaFormFieldTypes[fieldValueTypeName] ??
          _defaultVanillaFormFieldType;
    }
  }
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
