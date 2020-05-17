package com.example.weatherapp

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.fragment.app.Fragment
import kotlinx.android.synthetic.*
import kotlinx.android.synthetic.main.activity_detail.*
import kotlinx.android.synthetic.main.forecastfragment.*

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        var list = arrayListOf<String>(
            "박준성 ㄹㅇ 실화냐?",
            "내가알던 그 코딩못하던 박준성이 맞냐?",
            "진짜 박준성은 전설이다.",
            "박준성의 코딩실력을 보면 가슴이 웅장해진다"
        );
        var listView = findViewById<ListView>(R.id.listview);
        var adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1,list);
        listView.adapter = adapter;
//        listView.setOnClickListener {parent, view, position, id ->
//            Toast.makeText(this@MainActivity, "You have Clicked " + parent.getItemAtPosition(position), Toast.LENGTH_SHORT).show()
//        }
        listView.onItemClickListener = AdapterView.OnItemClickListener { parent, view, position, id ->
            var intent = Intent(this, DetailActivity::class.java).apply{
                putExtra("key",list[position]);
            }
            startActivity(intent);
        }
    }


}

class ForecastFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.forecastfragment, container, false)
    }
}