package com.piglixlabs.shadermakerformcpe

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.piglix.shader/launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openWithMinecraft") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    val file = File(filePath)
                    if (file.exists()) {
                        try {
                            val uri: Uri = FileProvider.getUriForFile(
                                this,
                                "${applicationContext.packageName}.fileprovider",
                                file
                            )

                            // Try direct intent to Minecraft Bedrock first
                            val mcIntent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(uri, "application/mcpack")
                                setPackage("com.mojang.minecraftpe")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }

                            if (mcIntent.resolveActivity(packageManager) != null) {
                                startActivity(mcIntent)
                                result.success(true)
                                return@setMethodCallHandler
                            }

                            // Fallback: general chooser with octet-stream MIME
                            val chooserIntent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(uri, "application/octet-stream")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            val chooser = Intent.createChooser(chooserIntent, "Open with Minecraft or File Manager")
                            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(chooser)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("OPEN_FAILED", e.localizedMessage, null)
                        }
                    } else {
                        result.error("FILE_NOT_FOUND", "File does not exist at $filePath", null)
                    }
                } else {
                    result.error("INVALID_PATH", "filePath is null", null)
                }
            } else if (call.method == "shareFile") {
                val filePath = call.argument<String>("filePath")
                val title = call.argument<String>("title") ?: "Share Shader Pack"
                if (filePath != null) {
                    val file = File(filePath)
                    if (file.exists()) {
                        try {
                            val uri: Uri = FileProvider.getUriForFile(
                                this,
                                "${applicationContext.packageName}.fileprovider",
                                file
                            )
                            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                                type = "application/octet-stream"
                                putExtra(Intent.EXTRA_STREAM, uri)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                            val chooser = Intent.createChooser(shareIntent, title).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(chooser)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SHARE_FAILED", e.localizedMessage, null)
                        }
                    } else {
                        result.error("FILE_NOT_FOUND", "File does not exist at $filePath", null)
                    }
                } else {
                    result.error("INVALID_PATH", "filePath is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
