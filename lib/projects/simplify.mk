# -*-makefile-*-



## evaluation tool
## fails on puhti
easse:
	git clone https://github.com/feralvam/easse.git
	cd $@ && pip install --user .

## do we need this?
text-simplification-evaluation:
	git clone git@github.com:facebookresearch/text-simplification-evaluation.git
	cd text-simplification-evaluation
	pip install -e . --user
	pip install --user -r requirements.txt



#---------------------------------------------------------------------
# simplification test set
#---------------------------------------------------------------------

simplification:
	git clone https://github.com/cocoxu/simplification.git

testsets/en-en/simplification.en1.gz: simplification
	mkdir -p ${dir $@}
	cut -f2  simplification/data/turkcorpus/truecased/test.8turkers.organized.tsv |\
	${TOKENIZER}/detokenizer.perl -l en | \
	gzip -c > $@

testsets/en-en/simplification.en2.gz: simplification
	mkdir -p ${dir $@}
	cut -f3  simplification/data/turkcorpus/truecased/test.8turkers.organized.tsv |\
	${TOKENIZER}/detokenizer.perl -l en | \
	gzip -c > $@

simplify-testset: testsets/en-en/simplification.en1.gz testsets/en-en/simplification.en2.gz


#---------------------------------------------------------------------
# document-level data
#---------------------------------------------------------------------

simplewiki-docdata: ${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-test.en-en.en1.raw \
		${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-test.en-en.en2.raw \
		${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-dev.en-en.en1.raw \
		${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-dev.en-en.en2.raw \
		${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-train.en-en.en1.raw \
		${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-train.en-en.en2.raw

${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en1.raw: ${HOME}/work/SimplifyRussian/data/simplification_datasets/simplewiki_docs.csv
	mkdir -p ${dir $@}
	tail -n +2 $< | cut -f2 |  sed 's/^"//;s/ "$$//' > $@.en1
	tail -n +2 $< | cut -f3 |  sed 's/^"//;s/ "$$//' > $@.en2
	$(MOSESSCRIPTS)/training/clean-corpus-n.perl $@ en1 en2 $@.clean 0 ${MARIAN_MAX_LENGTH}
	${TOKENIZER}/detokenizer.perl -l en < $@.clean.en1 > $@
	${TOKENIZER}/detokenizer.perl -l en < $@.clean.en2 > $(@:.en1.raw=.en2.raw)
	rm -f $@.en1 $@.en2 $@.clean.en1 $@.clean.en2

${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en2.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en1.raw
	@echo "done!"

${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-test.en-en.en1.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en1.raw
	head -1000 $< > $@

${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-test.en-en.en2.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en2.raw
	head -1000 $< > $@

${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-dev.en-en.en1.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en1.raw
	head -2000 $< | tail -1000 > $@

${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-dev.en-en.en2.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en2.raw
	head -2000 $< | tail -1000 > $@

${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-train.en-en.en1.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en1.raw
	tail -n +2001 $< > $@

${DATADIR}/${PRE}/simplewiki_v2_doc${MARIAN_MAX_LENGTH}-train.en-en.en2.raw: ${DATADIR}/simplify/simplewiki_v2_doc${MARIAN_MAX_LENGTH}.en-en.en2.raw
	tail -n +2001 $< > $@


#---------------------------------------------------------------------
# data from https://cs.pomona.edu/~dkauchak/simplification/
#---------------------------------------------------------------------

SIMPLEWIKI_DATA1_URL = https://cs.pomona.edu/~dkauchak/simplification/data.v1/
SIMPLEWIKI_DATA2_URL = https://cs.pomona.edu/~dkauchak/simplification/data.v2/

SIMPLEWIKI_DATA1 = data.v1.split
SIMPLEWIKI_DATA2_SENT = sentence-aligned.v2
SIMPLEWIKI_DATA2_DOC = document-aligned.v2


# v1 - standard split

${WORKHOME}/simplewiki/${SIMPLEWIKI_DATA1}:
	mkdir -p ${dir $@}
	${WGET} -O $@.tar.gz ${SIMPLEWIKI_DATA1_URL}/${SIMPLEWIKI_DATA1}.tar.gz
	tar -C ${dir $@} -xzf $@.tar.gz
	rm -f $@.tar.gz
	${TOKENIZER}/detokenizer.perl -l en < $@/normal.training.txt > ${DATADIR}/${PRE}/simplewiki_v1-training.en-en.en1.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/simple.training.txt > ${DATADIR}/${PRE}/simplewiki_v1-training.en-en.en2.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/normal.tuning.txt > ${DATADIR}/${PRE}/simplewiki_v1-tuning.en-en.en1.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/simple.tuning.txt > ${DATADIR}/${PRE}/simplewiki_v1-tuning.en-en.en2.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/normal.testing.txt > ${DATADIR}/${PRE}/simplewiki_v1-testing.en-en.en1.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/simple.testing.txt > ${DATADIR}/${PRE}/simplewiki_v1-testing.en-en.en2.raw


## v2 - sentence aligned - my split

${WORKHOME}/simplewiki/${SIMPLEWIKI_DATA2_SENT}:
	mkdir -p ${dir $@}
	${WGET} -O $@.tar.gz ${SIMPLEWIKI_DATA2_URL}/${SIMPLEWIKI_DATA2_SENT}.tar.gz
	tar -C ${dir $@} -xzf $@.tar.gz
	rm -f $@.tar.gz
	cut -f3 $@/normal.aligned | tail -n +10001 |\
	${TOKENIZER}/detokenizer.perl -l en > ${DATADIR}/${PRE}/simplewiki_v2_sent-training.en-en.en1.raw
	cut -f3 $@/simple.aligned | tail -n +10001 |\
	${TOKENIZER}/detokenizer.perl -l en > ${DATADIR}/${PRE}/simplewiki_v2_sent-training.en-en.en2.raw
	cut -f3 $@/normal.aligned | head -10000 | tail -5000 |\
	${TOKENIZER}/detokenizer.perl -l en > ${DATADIR}/${PRE}/simplewiki_v2_sent-tuning.en-en.en1.raw
	cut -f3 $@/simple.aligned | head -10000 | tail -5000 |\
	${TOKENIZER}/detokenizer.perl -l en > ${DATADIR}/${PRE}/simplewiki_v2_sent-tuning.en-en.en2.raw
	cut -f3 $@/normal.aligned | head -5000 |\
	${TOKENIZER}/detokenizer.perl -l en > ${DATADIR}/${PRE}/simplewiki_v2_sent-testing.en-en.en1.raw
	cut -f3 $@/simple.aligned | head -5000 |\
	${TOKENIZER}/detokenizer.perl -l en > ${DATADIR}/${PRE}/simplewiki_v2_sent-testing.en-en.en2.raw


simplewiki-v1-english-prepare: ${WORKHOME}/simplewiki/${SIMPLEWIKI_DATA1}

## train a simplification model from simplewiki for English

%-simplewiki-v1-english: ${WORKHOME}/simplewiki/${SIMPLEWIKI_DATA1}
	rm -f ${WORKDIR}/*.submit
	${MAKE} DATASET=simplewiki_v1 \
		SUBWORD_MODEL_NAME=simplewiki_v1 \
		TRAINSET=simplewiki_v1-training \
		DEVSET=simplewiki_v1-tuning \
		TESTSET=simplewiki_v1-testing \
		HELDOUTSIZE=0 \
		SRCLANGS=en TRGLANGS=en \
	${@:-simplewiki-v1-english=}

%-simplewiki-v2sent-english: ${WORKHOME}/simplewiki/${SIMPLEWIKI_DATA2_SENT}
	rm -f ${WORKDIR}/*.submit
	${MAKE} DATASET=simplewiki_v2_sent \
		SUBWORD_MODEL_NAME=simplewiki_v2_sent \
		TRAINSET=simplewiki_v2_sent-training \
		DEVSET=simplewiki_v2_sent-tuning \
		TESTSET=simplewiki_v2_sent-testing \
		HELDOUTSIZE=0 \
		SRCLANGS=en TRGLANGS=en \
	${@:-simplewiki-v2sent-english=}


%-simplewiki-v2doc-english: simplewiki-docdata
	rm -f ${WORKDIR}/*.submit
	${MAKE} DATASET=simplewiki_v2_doc \
		SUBWORD_MODEL_NAME=simplewiki_v2_doc${MARIAN_MAX_LENGTH} \
		TRAINSET=simplewiki_v2_doc${MARIAN_MAX_LENGTH}-train \
		DEVSET=simplewiki_v2_doc${MARIAN_MAX_LENGTH}-dev \
		TESTSET=simplewiki_v2_doc${MARIAN_MAX_LENGTH}-test \
		HELDOUTSIZE=0 MAX_NR_TOKENS=${MARIAN_MAX_LENGTH} \
		SRCLANGS=en TRGLANGS=en \
	    	MARIAN_VALID_FREQ=1000 \
	    	MARIAN_WORKSPACE=5000 \
		MARIAN_MAX_LENGTH=500 \
		HPC_MEM=12g \
	${@:-simplewiki-v2doc-english=}

#		MARIAN_EXTRA="--max-length-crop" \




%-simplewiki-v2sent+doc-english: ${WORKHOME}/simplewiki/${SIMPLEWIKI_DATA2_SENT} simplewiki-docdata
	rm -f ${WORKDIR}/*.submit
	${MAKE} DATASET=simplewiki_v2_sent+doc${MARIAN_MAX_LENGTH} \
		SUBWORD_MODEL_NAME=simplewiki_v2-sent+doc${MARIAN_MAX_LENGTH} \
		TRAINSET="simplewiki_v2_doc${MARIAN_MAX_LENGTH}-train simplewiki_v2_sent-training" \
		DEVSET=simplewiki_v2_doc${MARIAN_MAX_LENGTH}-dev \
		TESTSET=simplewiki_v2_doc${MARIAN_MAX_LENGTH}-test \
		HELDOUTSIZE=0 MAX_NR_TOKENS=${MARIAN_MAX_LENGTH} \
		SRCLANGS=en TRGLANGS=en \
	    	MARIAN_VALID_FREQ=1000 \
	    	MARIAN_WORKSPACE=5000 \
		HPC_MEM=16g \
	${@:-simplewiki-v2sent+doc-english=}



#---------------------------------------------------------------------
# data from https://github.com/XingxingZhang/dress
#---------------------------------------------------------------------


SIMPLEWIKI_LARGE_URL = https://github.com/louismartin/dress-data/raw/master/data-simplification.tar.bz2
SIMPLEWIKI_LARGE = data-simplification/wikilarge


${WORKHOME}/simplewiki/${SIMPLEWIKI_LARGE}:
	mkdir -p ${dir $@}
	${WGET} -O $@.tar.bz2 ${SIMPLEWIKI_LARGE_URL}
	tar -C ${dir $@} -xf $@.tar.bz2
	rm -f $@.tar.bz2
	${TOKENIZER}/detokenizer.perl -l en < $@/wiki.full.aner.train.src > ${DATADIR}/${PRE}/simplewiki_large-train.en-en.en1.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/wiki.full.aner.train.dst > ${DATADIR}/${PRE}/simplewiki_large-train.en-en.en2.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/wiki.full.aner.valid.src > ${DATADIR}/${PRE}/simplewiki_large-tune.en-en.en1.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/wiki.full.aner.valid.src > ${DATADIR}/${PRE}/simplewiki_large-tune.en-en.en2.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/wiki.full.aner.test.src > ${DATADIR}/${PRE}/simplewiki_large-test.en-en.en1.raw
	${TOKENIZER}/detokenizer.perl -l en < $@/wiki.full.aner.test.src > ${DATADIR}/${PRE}/simplewiki_large-test.en-en.en2.raw

simplelarge-english-prepare: ${WORKHOME}/simplewiki/${SIMPLEWIKI_LARGE}

%-simplewikilarge-english: ${WORKHOME}/simplewiki/${SIMPLEWIKI_LARGE}
	rm -f ${WORKDIR}/*.submit
	${MAKE} DATASET=simplewiki_large \
		SUBWORD_MODEL_NAME=simplewiki_large \
		TRAINSET=simplewiki_large-train \
		DEVSET=simplewiki_large-tune \
		TESTSET=simplewiki_large-test \
		HELDOUTSIZE=0 \
		SRCLANGS=en TRGLANGS=en \
	${@:-simplewikilarge-english=}
