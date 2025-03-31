// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../modules/categories/controller/categories_controller.dart' as _i55;
import '../../modules/categories/data/i_categories_repository.dart' as _i870;
import '../../modules/categories/data/i_categories_repository_impl.dart'
    as _i947;
import '../../modules/categories/service/i_categories_service.dart' as _i803;
import '../../modules/categories/service/i_categories_service_impl.dart'
    as _i465;
import '../../modules/chat/controller/chat_controller.dart' as _i194;
import '../../modules/chat/data/i_chat_repository.dart' as _i216;
import '../../modules/chat/data/i_chat_repository_impl.dart' as _i697;
import '../../modules/chat/service/i_chat_service.dart' as _i189;
import '../../modules/chat/service/i_chat_service_impl.dart' as _i989;
import '../../modules/schedule/controller/schedule_controller.dart' as _i1044;
import '../../modules/schedule/data/i_schedule_repository.dart' as _i154;
import '../../modules/schedule/data/i_schedule_repository_impl.dart' as _i699;
import '../../modules/schedule/service/i_schedule_service.dart' as _i513;
import '../../modules/schedule/service/i_schedule_service_impl.dart' as _i889;
import '../../modules/supplier/controller/supplier_controller.dart' as _i331;
import '../../modules/supplier/data/i_supplier_repository.dart' as _i417;
import '../../modules/supplier/data/i_supplier_repository_impl.dart' as _i566;
import '../../modules/supplier/service/i_supplier_service.dart' as _i448;
import '../../modules/supplier/service/i_supplier_service_impl.dart' as _i293;
import '../../modules/user/controller/auth_controller.dart' as _i477;
import '../../modules/user/controller/user_controller.dart' as _i983;
import '../../modules/user/data/i_user_repository.dart' as _i872;
import '../../modules/user/data/i_user_repository_impl.dart' as _i1014;
import '../../modules/user/service/i_user_service.dart' as _i610;
import '../../modules/user/service/i_user_service_impl.dart' as _i705;
import '../database/i_database_connection.dart' as _i77;
import '../database/i_database_connection_impl.dart' as _i795;
import '../facade/push_notification_facade.dart' as _i844;
import '../logs/i_log.dart' as _i1;
import 'database_connection_config.dart' as _i593;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i77.IDatabaseConnection>(() =>
        _i795.IDatabaseConnectionImpl(gh<_i593.DatabaseConnectionConfig>()));
    gh.lazySingleton<_i870.ICategoriesRepository>(
        () => _i947.CategoriesRepository(
              connection: gh<_i77.IDatabaseConnection>(),
              log: gh<_i1.ILog>(),
            ));
    gh.lazySingleton<_i216.IChatRepository>(() => _i697.ChatRepository(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i417.ISupplierRepository>(() => _i566.SupplierRepository(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i154.IScheduleRepository>(() => _i699.ScheduleRepository(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i872.IUserRepository>(() => _i1014.UserRepository(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i610.IUserService>(() => _i705.IUserServiceImpl(
          userRepository: gh<_i872.IUserRepository>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i844.PushNotificationFacade>(
        () => _i844.PushNotificationFacade(log: gh<_i1.ILog>()));
    gh.lazySingleton<_i803.ICategoriesService>(() =>
        _i465.CategoriesService(repository: gh<_i870.ICategoriesRepository>()));
    gh.lazySingleton<_i513.IScheduleService>(() => _i889.ScheduleService(
          repository: gh<_i154.IScheduleRepository>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i189.IChatService>(() => _i989.ChatService(
          repository: gh<_i216.IChatRepository>(),
          facade: gh<_i844.PushNotificationFacade>(),
        ));
    gh.factory<_i55.CategoriesController>(() =>
        _i55.CategoriesController(service: gh<_i803.ICategoriesService>()));
    gh.factory<_i194.ChatController>(() => _i194.ChatController(
          service: gh<_i189.IChatService>(),
          log: gh<_i1.ILog>(),
        ));
    gh.factory<_i477.AuthController>(() => _i477.AuthController(
          userService: gh<_i610.IUserService>(),
          log: gh<_i1.ILog>(),
        ));
    gh.factory<_i983.UserController>(() => _i983.UserController(
          userService: gh<_i610.IUserService>(),
          log: gh<_i1.ILog>(),
        ));
    gh.lazySingleton<_i448.ISupplierService>(() => _i293.SupplierService(
          gh<_i417.ISupplierRepository>(),
          gh<_i610.IUserService>(),
        ));
    gh.factory<_i1044.ScheduleController>(() => _i1044.ScheduleController(
          service: gh<_i513.IScheduleService>(),
          log: gh<_i1.ILog>(),
        ));
    gh.factory<_i331.SupplierController>(() => _i331.SupplierController(
          service: gh<_i448.ISupplierService>(),
          log: gh<_i1.ILog>(),
        ));
    return this;
  }
}
