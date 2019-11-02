/* global document window XMLHttpRequest */
document.addEventListener('DOMContentLoaded', () => {
  // https://bulma.io/documentation/components/navbar/
  // Get all 'navbar-burger' elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {
    // Add a click event on each of them
    $navbarBurgers.forEach((el) => {
      el.addEventListener('click', () => {
        // Get the target from the 'data-target' attribute
        const { target } = el.dataset;
        const $target = document.getElementById(target);

        // Toggle the 'is-active' class on both the 'navbar-burger' and the 'navbar-menu'
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');

      });
    });
  }

  // https://siongui.github.io/2018/01/19/bulma-dropdown-with-javascript/
  // Dropdowns

  function getAll(selector) {
    return Array.prototype.slice.call(document.querySelectorAll(selector), 0);
  }

  const $dropdowns = getAll('.dropdown:not(.is-hoverable)');

  function closeDropdowns() {
    $dropdowns.forEach(($el) => {
      $el.classList.remove('is-active');
    });
  }

  if ($dropdowns.length > 0) {
    $dropdowns.forEach(($el) => {
      $el.addEventListener('click', (event) => {
        event.stopPropagation();
        $el.classList.toggle('is-active');
      });
    });

    document.addEventListener('click', () => {
      closeDropdowns();
    });
  }

  // Close dropdowns if ESC pressed
  document.addEventListener('keydown', (event) => {
    const e = event || window.event;
    if (e.keyCode === 27) {
      closeDropdowns();
    }
  });


  // for Latte only

  // set delivery time
  const d = new Date();
  document.getElementById('local-time').innerText = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), 3, 0, 0)).toLocaleString('en-us', {hour: 'numeric', timeZoneName: 'short' });

  // get correct date
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  // if time has passed 3 AM UTC, return news from yesterday
  if (d.getUTCHours() >= 3) {
    d.setDate(d.getDate() - 1);
  } else { // return news from the day before yesterday
    d.setDate(d.getDate() - 2);
  }
  const utcDate = d.getUTCDate();
  const utcMonth = d.getUTCMonth();
  const utcYear = d.getUTCFullYear();

  const apiFormatedDate = `${utcYear}_${months[utcMonth]}_${utcDate}`;
  const uiFormatedDate = `${months[utcMonth]} ${utcDate}, ${utcYear}`;

  // populate news data
  // https://www.taniarascia.com/how-to-connect-to-an-api-with-javascript/
  const request = new XMLHttpRequest();

  // Open a new connection, using the GET request on the URL endpoint
  request.open('GET', `https://en.wikipedia.org/w/api.php?action=parse&section=0&prop=text&origin=*&format=json&page=Portal:Current_events/${apiFormatedDate}`, true);

  request.onload = function handleOnload() {
    const response = JSON.parse(this.response);
    const tmp = document.createElement('div');
    tmp.innerHTML = response.parse.text['*'];
    document.getElementById('today-title').innerText = uiFormatedDate;
    document.getElementById('wikipedia-content').innerHTML = tmp.getElementsByClassName('description')[0].innerHTML
      .replace(/"\/wiki/g, '"https://en.wikipedia.org/wiki');
    document.getElementById('wikipedia-contributors').setAttribute('href', `https://en.wikipedia.org/w/index.php?title=Portal:Current_events/${apiFormatedDate}&action=history`);
  };

  // Send request
  request.send();
});
