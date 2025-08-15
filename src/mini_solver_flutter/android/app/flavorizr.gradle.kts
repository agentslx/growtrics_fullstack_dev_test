import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.minisolver.app"
            resValue(type = "string", name = "app_name", value = "Mini Solver")
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.minisolver.app"
            resValue(type = "string", name = "app_name", value = "Mini Solver")
        }
    }
}