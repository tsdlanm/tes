<?php

namespace App\Http\Controllers;

use App\Models\LogBirdBuster;
use Illuminate\Http\Request;


class LogController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index() 
    {
        $logs = LogBirdBuster::all();
        return view('welcome',compact('logs'));
    }
    public function limadata()
    {
        //
        $logs = LogBirdBuster::orderBy('id','desc')->take(5)->get();
        return view('welcome',compact('logs'));

    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(LogBirdBuster $log)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(LogBirdBuster $log)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, LogBirdBuster $log)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(LogBirdBuster $log)
    {
        //
    }
}
