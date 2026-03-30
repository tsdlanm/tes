<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class LogBirdBuster extends Model
{
    //
    protected $connection = 'mongodb';
    // Explicitly set the MongoDB collection name
    protected $table = 'LogBirdBuster';

    protected $fillable = [  
            'Respon',
            'Durasi',
            'Tanggal',
            'Jam',
            ];
}
