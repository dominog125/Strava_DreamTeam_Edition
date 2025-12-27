@if ($paginator->hasPages())
    <nav
        role="navigation"
        aria-label="Pagination Navigation"
        class="mt-4 flex justify-center"
    >
        <ul class="inline-flex items-center gap-2 text-xs sm:text-sm">

            {{-- Previous Page Link --}}
            @if ($paginator->onFirstPage())
                <li>
                    <span
                        class="inline-flex items-center justify-center
                               px-4 py-1.5 font-semibold rounded-full
                               border border-gray-400/70
                               bg-gray-200/80 text-gray-500
                               dark:bg-gray-800/80 dark:border-gray-600 dark:text-gray-500
                               cursor-not-allowed opacity-70"
                    >
                        {!! __('pagination.previous') !!}
                    </span>
                </li>
            @else
                <li>
                    <a
                        href="{{ $paginator->previousPageUrl() }}"
                        rel="prev"
                        class="inline-flex items-center justify-center
                               px-4 py-1.5 font-semibold rounded-full
                               border border-orange-500
                               bg-gradient-to-r from-orange-500 to-orange-600
                               text-white shadow-md shadow-orange-500/40
                               hover:from-orange-600 hover:to-orange-700
                               focus:outline-none focus:ring-2 focus:ring-orange-400
                               focus:ring-offset-2 focus:ring-offset-gray-100
                               dark:focus:ring-offset-gray-900
                               transition"
                    >
                        « {{ __('pagination.previous') }}
                    </a>
                </li>
            @endif

            {{-- Pagination Elements --}}
            @foreach ($elements as $element)
                {{-- "Trzy kropki" --}}
                @if (is_string($element))
                    <li>
                        <span
                            class="inline-flex items-center justify-center
                                   px-3 py-1.5 rounded-full
                                   text-gray-500 dark:text-gray-400"
                        >
                            {{ $element }}
                        </span>
                    </li>
                @endif

                {{-- Numery stron --}}
                @if (is_array($element))
                    @foreach ($element as $page => $url)
                        @if ($page == $paginator->currentPage())
                            <li>
                                <span
                                    class="inline-flex items-center justify-center
                                           px-3 py-1.5 font-semibold rounded-full
                                           border border-orange-500
                                           bg-orange-500 text-white
                                           shadow-md shadow-orange-500/40"
                                >
                                    {{ $page }}
                                </span>
                            </li>
                        @else
                            <li>
                                <a
                                    href="{{ $url }}"
                                    class="inline-flex items-center justify-center
                                           px-3 py-1.5 font-semibold rounded-full
                                           border border-gray-300
                                           bg-gray-200/90 text-gray-800
                                           hover:border-orange-500 hover:bg-orange-500 hover:text-white
                                           dark:border-gray-700 dark:bg-gray-800/90 dark:text-gray-100
                                           dark:hover:bg-orange-500 dark:hover:border-orange-500
                                           transition"
                                >
                                    {{ $page }}
                                </a>
                            </li>
                        @endif
                    @endforeach
                @endif
            @endforeach

            {{-- Next Page Link --}}
            @if ($paginator->hasMorePages())
                <li>
                    <a
                        href="{{ $paginator->nextPageUrl() }}"
                        rel="next"
                        class="inline-flex items-center justify-center
                               px-4 py-1.5 font-semibold rounded-full
                               border border-orange-500
                               bg-gradient-to-r from-orange-500 to-orange-600
                               text-white shadow-md shadow-orange-500/40
                               hover:from-orange-600 hover:to-orange-700
                               focus:outline-none focus:ring-2 focus:ring-orange-400
                               focus:ring-offset-2 focus:ring-offset-gray-100
                               dark:focus:ring-offset-gray-900
                               transition"
                    >
                        {!! __('pagination.next') !!}
                    </a>
                </li>
            @else
                <li>
                    <span
                        class="inline-flex items-center justify-center
                               px-4 py-1.5 font-semibold rounded-full
                               border border-gray-400/70
                               bg-gray-200/80 text-gray-500
                               dark:bg-gray-800/80 dark:border-gray-600 dark:text-gray-500
                               cursor-not-allowed opacity-70"
                    >
                        {{ __('pagination.next') }} »
                    </span>
                </li>
            @endif
        </ul>
    </nav>
@endif
