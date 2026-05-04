// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/admin/data/repo_impl/admin_repo_impl.dart' as _i545;
import '../../features/admin/domain/repo/admin_repo.dart' as _i76;
import '../../features/admin/presentation/cubit/admin_cubit.dart' as _i684;
import '../../features/auth/data/datasource/auth_remote_data_source.dart'
    as _i24;
import '../../features/auth/data/repo_impl/auth_repo_impl.dart' as _i279;
import '../../features/auth/domain/repo/auth_repo.dart' as _i170;
import '../../features/auth/domain/usecases/check_auth.dart' as _i1011;
import '../../features/auth/domain/usecases/reset_password.dart' as _i1066;
import '../../features/auth/domain/usecases/sign_in.dart' as _i920;
import '../../features/auth/domain/usecases/sign_in_with_google.dart' as _i692;
import '../../features/auth/domain/usecases/sign_out.dart' as _i568;
import '../../features/auth/domain/usecases/sign_up.dart' as _i190;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/user/data/repo_impl/request_repo_impl.dart' as _i793;
import '../../features/user/domain/repo/request_repo.dart' as _i70;
import '../../features/user/presentation/cubit/profile_cubit.dart' as _i297;
import '../../features/user/presentation/cubit/request_cubit.dart' as _i899;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i24.AuthRemoteDataSource>(() => _i24.AuthRemoteDataSource());
    gh.lazySingleton<_i76.AdminRepository>(() => _i545.AdminRepoImpl());
    gh.factory<_i170.AuthRepository>(
      () => _i279.AuthRepoImpl(gh<_i24.AuthRemoteDataSource>()),
    );
    gh.factory<_i684.AdminCubit>(
      () => _i684.AdminCubit(gh<_i76.AdminRepository>()),
    );
    gh.lazySingleton<_i70.RequestRepository>(
      () => _i793.RequestRepositoryImpl(),
    );
    gh.factory<_i899.RequestCubit>(
      () => _i899.RequestCubit(gh<_i70.RequestRepository>()),
    );
    gh.factory<_i297.ProfileCubit>(
      () => _i297.ProfileCubit(gh<_i70.RequestRepository>()),
    );
    gh.factory<_i1011.CheckAuthUseCase>(
      () => _i1011.CheckAuthUseCase(gh<_i170.AuthRepository>()),
    );
    gh.factory<_i1066.ResetPasswordUseCase>(
      () => _i1066.ResetPasswordUseCase(gh<_i170.AuthRepository>()),
    );
    gh.factory<_i920.SignInUseCase>(
      () => _i920.SignInUseCase(gh<_i170.AuthRepository>()),
    );
    gh.factory<_i692.SignInWithGoogleUseCase>(
      () => _i692.SignInWithGoogleUseCase(gh<_i170.AuthRepository>()),
    );
    gh.factory<_i568.SignOutUseCase>(
      () => _i568.SignOutUseCase(gh<_i170.AuthRepository>()),
    );
    gh.factory<_i190.SignUpUseCase>(
      () => _i190.SignUpUseCase(gh<_i170.AuthRepository>()),
    );
    gh.lazySingleton<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        signIn: gh<_i920.SignInUseCase>(),
        signUp: gh<_i190.SignUpUseCase>(),
        signOut: gh<_i568.SignOutUseCase>(),
        resetPassword: gh<_i1066.ResetPasswordUseCase>(),
        checkAuth: gh<_i1011.CheckAuthUseCase>(),
        signInWithGoogle: gh<_i692.SignInWithGoogleUseCase>(),
      ),
    );
    return this;
  }
}
