import yaml
import argparse
import os

def parse():
	parser = argparse.ArgumentParser(description="Create CTM")
	parser.add_argument("text", help="Text one utterance per line")
	parser.add_argument("database", help="Yaml file containing the utterance database")
	parser.add_argument("ctm", help="output ctm file")
	args = parser.parse_args()
	return args

def process_filename(name):
	base_name = base=os.path.basename(name)
	# stm filename: ted.tst2014.talkid1443.en-xy.en
	result = "ted." + base_name.replace(".wav", "").replace("en.", "") + ".en-xy.en"
	return result


if __name__ == '__main__':
	args = parse()

	with open(args.database, "r") as f:
		database = yaml.load(f)

	with open(args.ctm, "w") as fo:
		with open(args.text, "r") as fi:
			for utt_id, line in enumerate(fi):
				words = line.split()
				if len(words) == 0:
					continue

				utt_info = database[utt_id]
				file = process_filename(utt_info["wav"])
				channel = 1
				# just assume that each word has the same duration
				duration = utt_info["duration"] / float(len(words))
				
				# CTM Format :== <F> <C> <BT> <DUR> word <CONF>
				for i, word in enumerate(words):
					begin_time = utt_info["offset"] + utt_info["duration"] * i
					fo.write("{} {} {:.2f} {:.2f} {}\n".format(file, channel, begin_time, duration, word))

