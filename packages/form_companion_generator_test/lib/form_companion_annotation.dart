// See LICENCE file in the root.

// ignore_for_file: type=lint

import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class Default {}

@FormCompanion(autovalidate: false)
class AutovalidateIsFalse {}

@FormCompanion(autovalidate: true)
class AutovalidateIsTrue {}

@FormCompanion(suppressFieldFactory: true)
class SuppressFieldFactoryIsTrue {}

@FormCompanion(suppressFieldFactory: false)
class SuppressFieldFactoryIsFalse {}
