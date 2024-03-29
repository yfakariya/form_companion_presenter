// See LICENCE file in the root.

/// Defines mixin and helpers to build presenter of form widget which uses
/// flutter native form field classes.
library;

export 'src/async_validator_executor.dart'
    show
        AsyncValidationCompletionCallback,
        AsyncValidationFailureHandler,
        AsyncValidator,
        AsyncValidatorExecutor,
        AsyncValidatorOptions,
        ValidationInvocation;
export 'src/form_companion_mixin.dart'
    show
        AsyncValidatorFactory,
        CompanionPresenterFeatures,
        CompanionPresenterMixin,
        CompanionPresenterMixinExtension,
        FormCompanionMixin,
        FormCompanionPropertyDescriptorsBuilderExtension,
        FormFieldValidatorFactory,
        FormProperties,
        FormPropertiesExtension,
        FormStateAdapter,
        OnPropertiesChangedEvent,
        PropertyDescriptor,
        PropertyDescriptorsBuilder,
        RestorableValueFactory,
        ValidatorCreationOptions,
        bigIntRestorableValueFactory,
        boolRestorableValueFactory,
        createValidatorCreationOptions,
        dateTimeRangeRestorableValueFactory,
        dateTimeRestorableValueFactory,
        doubleRestorableValueFactory,
        enumListRestorableValueFactory,
        enumRestorableValueFactory,
        intRestorableValueFactory,
        rangeValuesRestorableValueFactory,
        stringRestorableValueFactory;
export 'src/future_invoker.dart'
    show
        AsyncErrorHandler,
        AsyncInvocationFailureContext,
        AsyncOperationCompletedCallback,
        AsyncOperationFailedCallback,
        AsyncOperationFailureHandler,
        AsyncOperationNotifier,
        AsyncOperationProgressCallback,
        AsyncOperationStatus,
        FutureInvoker;
export 'src/number_converter.dart'
    show bigIntDoubleConverter, intDoubleConverter;
export 'src/property_value_traits.dart' show PropertyValueTraits;
export 'src/restoration.dart' show FormPropertiesRestorationScope;
export 'src/string_converter.dart'
    show
        ParseFailureMessageProvider,
        Parser,
        StringConverter,
        Stringifier,
        bigIntStringConverter,
        dateTimeStringConverter,
        doubleStringConverter,
        intStringConverter,
        uriStringConverter;
export 'src/value_converter.dart'
    show
        ConversionResult,
        FailureResult,
        FieldToPropertyConverter,
        PropertyToFieldConverter,
        SomeConversionResult,
        ValueConverter;

// for testing
// Enable this line to take effect logs in tests in form_builder_companion_presenter package.
// export 'src/internal_utils.dart' show loggerSink, Logger, LogLevel, LoggerSink;
