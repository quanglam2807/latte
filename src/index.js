const Mailchimp = require('mailchimp-api-v3');
const axios = require('axios');
const cheerio = require('cheerio');

const MAILCHIMP_LIST_ID = 'b892a7798a';

const mailchimp = new Mailchimp(process.env.MAILCHIMP_API_KEY);

const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

const getLatestDateObj = () => {
  const d = new Date();

  // get correct date
  // if time has passed 3 AM UTC, return news from yesterday
  if (d.getUTCHours() >= 3) {
    d.setDate(d.getDate() - 1);
  } else { // return news from the day before yesterday
    d.setDate(d.getDate() - 2);
  }

  return d;
};

const getLatestApiDateString = () => {
  const d = getLatestDateObj();

  const utcDate = d.getUTCDate();
  const utcMonth = d.getUTCMonth();
  const utcYear = d.getUTCFullYear();

  return `${utcYear}_${months[utcMonth]}_${utcDate}`;
};

const getLatestUiDateString = () => {
  const d = getLatestDateObj();

  const utcDate = d.getUTCDate();
  const utcMonth = d.getUTCMonth();
  const utcYear = d.getUTCFullYear();

  return `${months[utcMonth]} ${utcDate}, ${utcYear}`;
};

const getLatestLongUiDateString = () => {
  const d = getLatestDateObj();

  const utcDay = d.getUTCDay();
  const utcDate = d.getUTCDate();
  const utcMonth = d.getUTCMonth();
  const utcYear = d.getUTCFullYear();

  return `${daysOfWeek[utcDay]}, ${months[utcMonth]} ${utcDate}, ${utcYear}`;
};

console.log('CAMPAIGN', getLatestLongUiDateString());

Promise.resolve()
  // Get latest campaign
  .then(() => {
    console.log('Getting latest campaign...');
    const opts = { count: 1, sort_field: 'create_time', sort_dir: 'DESC' };
    return mailchimp.get('/campaigns', opts);
  })
  .then((results) => {
    const { campaigns } = results;

    // Make sure campaign does not exist before creating
    const existingCampaign = campaigns
      .find((campaign) => campaign.settings.title.includes(getLatestUiDateString()));

    // If the campaign exists, return its ID.
    if (existingCampaign) {
      console.log('Use existing campaign', existingCampaign.id);
      return existingCampaign.id;
    }

    // If not, create new campaign
    console.log('Creating new campaign...');
    const opts = {
      type: 'regular',
      recipients: { list_id: MAILCHIMP_LIST_ID },
      settings: {
        subject_line: `${getLatestUiDateString()} - Latte`,
        preview_text: `Latest news from around the globe, on ${getLatestUiDateString()}`,
        title: `${getLatestUiDateString()} - Latte`,
        from_name: 'Latte',
        reply_to: 'latteapp.developer@gmail.com',
      },
    };
    return mailchimp.post('/campaigns', opts)
      .then((rr) => {
        console.log('Created campaign', rr.id);
        return rr.id;
      });
  })
  .then((campaignId) => {
    // Get campaign details to confirm
    const opts = {};
    return mailchimp.get(`/campaigns/${campaignId}/`, opts)
      .then((rr) => {
        if (rr.status !== 'sent') {
          console.log('Campaign has not been sent. Continuing...');
          return campaignId;
        }
        console.log('Campaign has been sent. Skipped.');
        return null;
      });
  })
  .then((campaignId) => {
    if (!campaignId) {
      return null;
    }

    // Get news content first
    console.log('Getting content from Wikipedia...');
    return axios.get(`https://en.wikipedia.org/w/api.php?action=parse&section=0&prop=text&origin=*&format=json&page=Portal:Current_events/${getLatestApiDateString()}`)
      .then((response) => {
        const fullHtml = response.data.parse.text['*'];
        const $ = cheerio.load(fullHtml);

        const headerHtml = `
<a title="Latte" href="https://quanglam2807.com/latte"><img src="https://gallery.mailchimp.com/59fd4de5e538554cf2e4382b7/images/9cf347a3-c082-4b1a-9835-405f526eb6a9.png" height="50" with="214"></a>
<h1 style="margin: 0;font-size: 1.25rem;font-weight: 600;text-transform: capitalize;margin-bottom: 1.5rem !important">${getLatestLongUiDateString()}</h1>
`;
        const extractedHtml = $('.description').html()
          .replace(/role="heading" style="margin-top:0.3em; font-size:inherit; font-weight:bold;"/g, 'style="margin: 0;font-weight: 600;"')
          .replace(/"\/wiki/g, '"https://en.wikipedia.org/wiki');
        const copyrightHtml = `<hr /><p style="font-size: .875em;">Original text authored by <a href="https://en.wikipedia.org/w/index.php?title=Portal:Current_events/${getLatestApiDateString()}&action=history" id="wikipedia-contributors">Wikipedia contributors</a> and available under the <a href="https://creativecommons.org/licenses/by-sa/3.0/us/">Creative Commons Attribution-ShareAlike License</a>.</p>`;

        // Update campaign content
        console.log('Updating campaign content...');
        const opts = {
          html: `${headerHtml}${extractedHtml}${copyrightHtml}`,
        };
        return mailchimp.put(`/campaigns/${campaignId}/content`, opts);
      })
      .then(() => {
        const opts = {};
        return mailchimp.post(`/campaigns/${campaignId}/actions/send`, opts);
      })
      .then(() => {
        console.log('Campaign has been sent successfully!');
      });
  })
  .catch(console.log);
