<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\JsonLogController;

Route::get('/halo',[JsonLogController::class,'index']);
