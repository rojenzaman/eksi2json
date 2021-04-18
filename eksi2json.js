const puppeteer = require('puppeteer');
const fs = require('fs');
const fsPromises = fs.promises;

const user = process.argv[2];
if (!user) {
    throw new Error("enter user name as an argument.")
}
const url = `https://eksisozluk.com/biri/${user.replace(/\s/g, '-')}`
console.log(`opening ${url} with puppeteer`);

(async () => {
    //const browser = await puppeteer.launch({ headless: false });
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    await page.goto(url);
    //click the more button to load all of quote
    const elem = await page.$('a#read-all');
    await elem.evaluate(elem => elem.click());
    console.log("page is loaded.")
    console.log("getting profile...");

    const profile = await page.evaluate(() => {
        async function load_profile() {
            //get profile in json object format
            return Array.from(document.querySelectorAll("section#content-body")).map(function(elem, index, arr) {
                var quote = elem.querySelector("blockquote#quote-entry div.content").innerHTML
                var quote_title = elem.querySelector("blockquote#quote-entry h2").innerText
                var quote_date = elem.querySelector("blockquote#quote-entry footer a.entry-date.permalink").innerText
                var quote_link = elem.querySelector("blockquote#quote-entry footer a.entry-date.permalink").href
                var badges = elem.querySelector("ul#user-badges").innerHTML
                var count = elem.querySelector("li#entry-count-total").innerText
                return {
                    quote,
                    quote_title,
                    quote_date,
                    quote_link,
                    badges,
                    count
                }
            })
        }

        return load_profile()

    });

    await page.goto(url);
    console.log("page is reloaded.")
    console.log("getting entries...");
    const entries = await page.evaluate(() => {
        async function yukle_entry() {
            //load entries until button is hidden
            var elem = $("a.load-more-entries")[0]
            while ($("a.load-more-entries")[0].getAttribute("class").indexOf("hidden") == -1) {
                elem.click()
                await new Promise(r => setTimeout(r, 500));
            }
            //get all entries in json object format
            return Array.from(document.querySelectorAll("div.topic-item")).map(function(elem, index, arr) {
                var title = elem.querySelector("#title").innerText
                var entry = elem.querySelector("#entry-item-list .content").innerHTML
                var date = elem.querySelector("#entry-item-list .entry-date").innerText
                var link = elem.querySelector("#entry-item-list .entry-date").href
                return {
                    title,
                    entry,
                    date,
                    link
                }
            })
        }

        return yukle_entry()

    });

    const archive = {
        entries,
        profile
    }
    console.log("objects are written to the file: " + `${user}.json`)
    await fsPromises.writeFile(`${user}.json`, JSON.stringify(archive, null, 2))

    await browser.close();

})();
