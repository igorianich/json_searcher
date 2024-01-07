document.addEventListener('DOMContentLoaded', function () {
    var searchInput = document.getElementById('searchInput');
    var resultsContainer = document.getElementById('searchResults');

    searchInput.addEventListener('input', function () {
        var searchQuery = searchInput.value.trim();

        if (searchQuery.length >= 1) {
            searchOnServer(searchQuery);
        } else {
            resultsContainer.innerHTML = '';
        }
    });

    function searchOnServer(query) {
        fetch('/search', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: 'query=' + encodeURIComponent(query),
        })
            .then(response => response.json())
            .then(results => {
                displayResults(results);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    function displayResults(results) {
        resultsContainer.innerHTML = '';

        if (results.length > 0) {
            var table = document.createElement('table');
            table.className = 'results-table';

            // Table header
            var headerRow = document.createElement('tr');
            for (var key in results[0]) {
                var headerCell = document.createElement('th');
                headerCell.textContent = key;
                headerRow.appendChild(headerCell);
            }
            table.appendChild(headerRow);

            // Table body
            results.forEach(function (result) {
                var row = document.createElement('tr');
                for (var key in result) {
                    var cell = document.createElement('td');
                    cell.textContent = result[key];
                    row.appendChild(cell);
                }
                table.appendChild(row);
            });

            resultsContainer.appendChild(table);
        } else {
            resultsContainer.innerHTML = '<p class="no-results">No results found.</p>';
        }
    }

});
