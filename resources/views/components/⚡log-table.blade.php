<?php

use App\Models\LogBirdBuster;
use Livewire\Component;

new class extends Component
{
    public bool $showAll = false;

    public function loadAll(): void
    {
        $this->showAll = true;
    }

    public function getLogsProperty()
    {
        $query = LogBirdBuster::orderBy('id', 'desc');

        return $this->showAll ? $query->get() : $query->take(5)->get();
    }
};
?>

<div class="max-w-4xl mx-auto mt-10 w-full">
    <h1 class="text-2xl font-bold mb-6 text-gray-800">Log</h1>

    <div class="overflow-x-auto bg-white rounded-xl shadow border border-gray-200">
        <table class="min-w-full text-sm text-left text-gray-600">
            <thead class="bg-gray-100 text-xs uppercase text-gray-700">
                <tr>
                    <th class="px-6 py-3">Respon</th>
                    <th class="px-6 py-3">Durasi</th>
                    <th class="px-6 py-3">Tanggal</th>
                    <th class="px-6 py-3">Jam</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($this->logs as $log)
                    <tr class="hover:bg-gray-50 transition">
                        <td class="px-6 py-4 font-medium text-gray-900">{{ $log->Respon }}</td>
                        <td class="px-6 py-4">{{ $log->Durasi }}</td>
                        <td class="px-6 py-4">{{ $log->Tanggal }}</td>
                        <td class="px-6 py-4">{{ $log->Jam }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-6 py-4 text-center text-gray-500">Belum ada data.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if (!$showAll)
        <div class="mt-4">
            <button
                type="button"
                wire:click="loadAll"
                wire:loading.attr="disabled"
                wire:target="loadAll"
                class="px-4 py-2 rounded bg-black text-white hover:bg-gray-800 transition"
            >
                <span wire:loading.remove wire:target="loadAll">Tampilkan Semua</span>
                <span wire:loading wire:target="loadAll" class="inline-flex items-center gap-2">
                    <svg class="h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                        <circle class="opacity-30" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-90" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
                    </svg>
                    Memuat...
                </span>
            </button>

            <div wire:loading wire:target="loadAll" class="mt-2 text-sm text-gray-500">
                Mengambil semua data, mohon tunggu...
            </div>
        </div>
    @endif
</div>