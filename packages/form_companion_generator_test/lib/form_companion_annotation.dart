// See LICENCE file in the root.

// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';

@formCompanion
class Default {}

@FormCompanion()
class Empty {}

@FormCompanion(autovalidate: false)
class AutovalidateIsFalse {}

@FormCompanion(autovalidate: true)
class AutovalidateIsTrue {}

@FormCompanion(suppressFieldFactory: true)
class SuppressFieldFactoryIsTrue {}

@FormCompanion(suppressFieldFactory: false)
class SuppressFieldFactoryIsFalse {}

@visibleForTesting
class AnotherAnnotation {}
