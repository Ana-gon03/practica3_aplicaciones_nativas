package com.example.practica3;

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import com.example.filemanager.databinding.ActivityMainBinding
import com.example.filemanager.utils.FileUtils
import com.example.filemanager.utils.PermissionUtils
import java.io.File

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: FileAdapter
    private var currentPath: String = FileUtils.getRootPath()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        PermissionUtils.requestStoragePermission(this)

        adapter = FileAdapter { fileItem -> onFileClicked(fileItem) }
        binding.recyclerView.layoutManager = GridLayoutManager(this, 2)
        binding.recyclerView.adapter = adapter

        listFiles(currentPath)

        binding.btnBack.setOnClickListener {
            val parent = File(currentPath).parentFile
            if (parent != null && parent.canRead()) {
                currentPath = parent.path
                listFiles(currentPath)
            }
        }
    }

    private fun listFiles(path: String) {
        val files = FileUtils.listFiles(path)
        adapter.submitList(files)
        binding.tvPath.text = path
    }

    private fun onFileClicked(item: FileItem) {
        if (item.isDirectory) {
            currentPath = item.path
            listFiles(currentPath)
        } else {
            when {
                FileUtils.isImage(item.name) -> {
                    val intent = Intent(this, ImageViewerActivity::class.java)
                    intent.putExtra("path", item.path)
                    startActivity(intent)
                }
                FileUtils.isTextFile(item.name) -> {
                    val intent = Intent(this, FileViewerActivity::class.java)
                    intent.putExtra("path", item.path)
                    startActivity(intent)
                }
                else -> FileUtils.openWithExternalApp(this, item.path)
            }
        }
    }
}
