// frontend heroes feel free to come to the rescue :)
document.addEventListener("DOMContentLoaded", function(event) { 
	var content = '';
	var meta = '';
	var size = {
					atr : {min:  360, max: 0, id: {min: 0, max: 0}},
					chr : {min: 4000, max: 0, id: {min: 0, max: 0}},
					map : {min:  360, max: 0, id: {min: 0, max: 0}}
				};
	var cycles = {
					atr : {min: 0, max: 0, id: {min: 0, max: 0}},
					chr : {min: 0, max: 0, id: {min: 0, max: 0}},
					map : {min: 0, max: 0, id: {min: 0, max: 0}}
				};

	var tgain = {
					val : {min:  100, max: 0},
					id  : {min: 0, max: 0},
					tmp : 0
				};

	var tcycles = {
					val : {min:  3966148, max: 0},
					id  : {min: 0, max: 0},
					tmp : 0
				};

	var json = JSON.parse(data);

	json.forEach(function(item, index) {
		if (index == 0)
			content += '<tr class="uk-text-muted">';
		else
			content += '<tr>';
		content += '<td class="uk-text-left">' + item.method + '&nbsp;';
		if (item.url.bin != "") {
			content += '<a href="' + item.url.bin + '" uk-icon="download" uk-tooltip="title: Packer executable"></a>&nbsp;';
		}
		if (item.url.src != "") {
			content += '<a href="' + item.url.src + '" uk-icon="file-text" uk-tooltip="title: Unpacker source"></a>';
		}
		content += '<td id="as' + index + '">' + item.atr.size + '</td>';
		content += '<td>' + (((1 - item.atr.size / 360) * 100).toFixed(2)) + '%</td>';
		content += '<td id="ac' + index + '">' + item.atr.cycles + '</td>';
		content += '<td id="cs' + index + '">' + item.chr.size + '</td>';
		content += '<td>' + (((1 - item.chr.size / 4000) * 100).toFixed(2)) + '%</td>';
		content += '<td id="cc' + index + '">' + item.chr.cycles + '</td>';
		content += '<td id="ms' + index + '">' + item.map.size +' </td>';
		content += '<td>' + (((1 - item.map.size / 360) * 100).toFixed(2)) + '%</td>';
		content += '<td id="mc' + index + '">' + item.map.cycles + '</td>';
		tgain.tmp = (((1 - (item.atr.size + item.chr.size + item.map.size) / (360 + 4000 + 360)) * 100).toFixed(2));
		content += '<td id="tg' + index + '">' + tgain.tmp + '%</td>';
		if (item.atr.cycles != '-' && item.chr.cycles != '-' && item.map.cycles  != '-') {
			tcycles.tmp = (item.atr.cycles + item.chr.cycles + item.map.cycles);
			content += '<td id="tc' + index + '">' + tcycles.tmp + '</td>';
		}
		else {
			tcycles.tmp = 0;
			content += '<td>-</td>';
		}
		content += '</tr>';

		meta += '<tr>';
		meta += '<td class="uk-text-left">' + item.method + '&nbsp;';
		if (item.url.bin != "") {
			meta += '<a href="' + item.url.bin + '" uk-icon="download" uk-tooltip="title: Packer executable"></a>&nbsp;';
		}
		if (item.url.src != "") {
			meta += '<a href="' + item.url.src + '" uk-icon="file-text" uk-tooltip="title: Unpacker source"></a>';
		}
		meta += '<td>' + item.unpacker.size + '</td>';
		meta += '<td>' + item.unpacker.ram + '</td>';
		meta += '<td>' + item.unpacker.hram + '</td>';
		meta += '<td>' + item.unpacker.header + '</td>';
		meta += '</tr>';

		// skip raw data at index 0
		if (index > 0) {

			// sizes
			if (size.atr.min > item.atr.size) {
				size.atr.min = item.atr.size;
				size.atr.id.min = index;
			}

			if (size.atr.max < item.atr.size) {
				size.atr.max = item.atr.size;
				size.atr.id.max = index;
			}

			if (size.chr.min > item.chr.size) {
				size.chr.min = item.chr.size;
				size.chr.id.min = index;
			}

			if (size.chr.max < item.chr.size) {
				size.chr.max = item.chr.size;
				size.chr.id.max = index;
			}

			if (size.map.min > item.map.size) {
				size.map.min = item.map.size;
				size.map.id.min = index;
			}

			if (size.map.max < item.map.size) {
				size.map.max = item.map.size;
				size.map.id.max = index;
			}

			// cycles
			if (cycles.atr.min > item.atr.cycles || cycles.atr.min === 0) {
				cycles.atr.min = item.atr.cycles;
				cycles.atr.id.min = index;
			}

			if (cycles.atr.max < item.atr.cycles) {
				cycles.atr.max = item.atr.cycles;
				cycles.atr.id.max = index;
			}

			if (cycles.chr.min > item.chr.cycles || cycles.chr.min === 0) {
				cycles.chr.min = item.chr.cycles;
				cycles.chr.id.min = index;
			}

			if (cycles.chr.max < item.chr.cycles) {
				cycles.chr.max = item.chr.cycles;
				cycles.chr.id.max = index;
			}

			if (cycles.map.min > item.map.cycles || cycles.map.min === 0) {
				cycles.map.min = item.map.cycles;
				cycles.map.id.min = index;
			}

			if (cycles.map.max < item.map.cycles) {
				cycles.map.max = item.map.cycles;
				cycles.map.id.max = index;
			}

			// total gain
			if (tgain.val.max < tgain.tmp) {
				tgain.val.max = tgain.tmp;
				tgain.id.max = index;
			}

			if (tgain.val.min > tgain.tmp) {
				tgain.val.min = tgain.tmp;
				tgain.id.min = index;
			}

			// total cycles
			if (tcycles.tmp != 0 && tcycles.val.max < tcycles.tmp) {
				tcycles.val.max = tcycles.tmp;
				tcycles.id.max = index;
			}

			if (tcycles.tmp != 0 && tcycles.val.min > tcycles.tmp) {
				tcycles.val.min = tcycles.tmp;
				tcycles.id.min = index;
			}
		}
	});

	var tbody = document.getElementById("results");
	tbody.innerHTML = content;

	var element = document.getElementById("as" + size.atr.id.min);
	element.classList.add("uk-text-success");
	element = document.getElementById("as" + size.atr.id.max);
	element.classList.add("uk-text-danger");
	element = document.getElementById("cs" + size.chr.id.min);
	element.classList.add("uk-text-success");
	element = document.getElementById("cs" + size.chr.id.max);
	element.classList.add("uk-text-danger");
	element = document.getElementById("ms" + size.map.id.min);
	element.classList.add("uk-text-success");
	element = document.getElementById("ms" + size.map.id.max);
	element.classList.add("uk-text-danger");

	element = document.getElementById("ac" + cycles.atr.id.min);
	element.classList.add("uk-text-success");
	element = document.getElementById("ac" + cycles.atr.id.max);
	element.classList.add("uk-text-danger");
	element = document.getElementById("cc" + cycles.chr.id.min);
	element.classList.add("uk-text-success");
	element = document.getElementById("cc" + cycles.chr.id.max);
	element.classList.add("uk-text-danger");
	element = document.getElementById("mc" + cycles.map.id.min);
	element.classList.add("uk-text-success");
	element = document.getElementById("mc" + cycles.map.id.max);
	element.classList.add("uk-text-danger");

	element = document.getElementById("tg" + tgain.id.max);
	element.classList.add("uk-text-success");
	element = document.getElementById("tg" + tgain.id.min);
	element.classList.add("uk-text-danger");

	element = document.getElementById("tc" + tcycles.id.max);
	element.classList.add("uk-text-danger");
	element = document.getElementById("tc" + tcycles.id.min);
	element.classList.add("uk-text-success");

	tbody = document.getElementById("meta");
	tbody.innerHTML = meta;

	json = JSON.parse(changelog);
	content = '';

	content += '<ul class="uk-switcher uk-margin chnglog">';
	json.forEach(function(item) {
		content += '<li><span class="uk-margin-remove uk-text-small uk-text-uppercase">' + item.date + '</span>';
		content += '<p class="uk-text-justify">' + item.text + '</p></li>';
	});
	content += '</ul>'

	content += '<ul class="uk-pagination uk-flex-center" uk-margin uk-switcher="connect: .chnglog">';
	json.forEach(function(item, index) {
		content += '<li><a href="#">' + (index + 1) + '</a></li>';
	});
	content += '</ul>'


	// [0,1,2].forEach(item => {
	// 	content += '<dt class="uk-margin-remove">' + json[item].date + '</dt>';
	// 	content += '<dd class="uk-padding-small uk-text-justify uk-text-small">' + json[item].text + '</dd>';
	// });
	// json.forEach(function(item) {
	// 	content += '<dt class="uk-margin-remove">' + item.date + '</dt>';
	// 	content += '<dd class="uk-padding-small uk-text-justify uk-text-small">' + item.text + '</dd>';
	// });

	var dl = document.getElementById("changelog");
	dl.innerHTML = content;

});
