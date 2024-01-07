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
            results.forEach(function (result) {
                var resultElement = document.createElement('div');
                resultElement.textContent = JSON.stringify(result);
                resultsContainer.appendChild(resultElement);
            });
        } else {
            resultsContainer.textContent = 'No results found.';
        }
    }
});
